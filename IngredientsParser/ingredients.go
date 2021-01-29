package main

// [START import]
import (
	"os"
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"strconv"
	"strings"
	"sync"

	"github.com/PuerkitoBio/goquery"
	"github.com/schollz/ingredients"
	"github.com/schollz/instructions"
	log "github.com/schollz/logger"
)

// [END import]
// [START main_func]

func main() {
	http.HandleFunc("/", indexHandler)

	// [START setting_port]
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
		log.Debug("Defaulting to port", port)
	}

	log.Debug("Listening on port", port)
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Debug(err)
	}
	// [END setting_port]
}

// [END main_func]

// [START indexHandler]

// indexHandler responds to requests with our greeting.
func indexHandler(w http.ResponseWriter, r *http.Request) {
	recipeURL := r.URL.Query().Get("url")
	var response []byte

	result, err := getRecipe(recipeURL)
	if err != nil {
		res := struct {
			Message string `json:"message"`
			Success bool   `json:"success"`
		}{
			err.Error(),
			false,
		}
		response, _ = json.Marshal(res)
	} else {
		response, _ = json.Marshal(result)
	}
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Access-Control-Max-Age", "86400")
	w.Header().Set("Access-Control-Allow-Methods", "GET,POST")
	w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, X-Max")
	w.Header().Set("Access-Control-Allow-Credentials", "true")
	w.Header().Set("Content-Type", "text/javascript")
	w.Header().Set("Content-Length", strconv.Itoa(len(response)))
	w.Write(response)
}

type SiteInfo struct {
	Title        string                   `json:"title"`
	Description  string                   `json:"description"`
	URL          string                   `json:"url"`
	Ingredients  []ingredients.Ingredient `json:"ingredients"`
	Instructions []string                 `json:"instructions"`
	ImageURL     string                   `json:"image"`
}

func getRecipe(urlCheck string) (si SiteInfo, err error) {
	si.URL = urlCheck

	req, err := http.NewRequest("GET", si.URL, nil)
	if err != nil {
		log.Debug(si.URL, err)
		return
	}
	req.Header.Set("Upgrade-Insecure-Requests", "1")
	req.Header.Set("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.142 Safari/537.36")
	req.Header.Set("Referer", "https://www.google.com/")

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		log.Debug(si.URL, err)
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		err = fmt.Errorf("bad error code: %d", resp.StatusCode)
		return
	}
	var bodyBytes []byte
	bodyBytes, err = ioutil.ReadAll(resp.Body)
	if err != nil {
		log.Debug(si.URL, err)
		return
	}
	htmlString := string(bodyBytes)

	var wg sync.WaitGroup
	wg.Add(3)
	go func() {
		defer wg.Done()
		ring, errR := ingredients.NewFromString(htmlString)
		if errR == nil {
			si.Ingredients = ring.IngredientList().Ingredients
		} else {
			log.Debug(errR)
		}
	}()

	go func() {
		defer wg.Done()
		rinc, errR := instructions.Parse(htmlString)
		if errR == nil {
			si.Instructions = rinc
		} else {
			log.Debug(errR)
		}
	}()

	go func() {
		defer wg.Done()
		doc, err := goquery.NewDocumentFromReader(bytes.NewReader([]byte(htmlString)))
		if err != nil {
			return
		}

		doc.Find("meta").Each(func(i int, s *goquery.Selection) {
			name := s.AttrOr("name", "")
			property := s.AttrOr("property", "")
			if (strings.Contains(name, ":title") || strings.Contains(property, ":title")) && si.ImageURL == "" {
				si.Title = s.AttrOr("content", "")
			}
			if (strings.Contains(name, ":description") || strings.Contains(property, ":description")) && si.ImageURL == "" {
				si.Description = s.AttrOr("content", "")
			}
			if (strings.Contains(name, ":image") || strings.Contains(property, ":image")) && si.ImageURL == "" {
				si.ImageURL = s.AttrOr("content", "")
			}
		})
		si.Title = strings.TrimSpace(si.Title)
		si.Description = strings.TrimSpace(si.Description)
		si.ImageURL = strings.TrimSpace(si.ImageURL)

		if si.Title == "" {
			doc.Find("title").Each(func(i int, s *goquery.Selection) {
				si.Title = strings.TrimSpace(s.Text())
			})
		}
	}()

	wg.Wait()

	return

}

// [END indexHandler]
// [END gae_go111_app]