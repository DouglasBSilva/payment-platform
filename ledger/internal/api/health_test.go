package api

import (
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestGetServer(t *testing.T) {
	t.Run("Test if health is working", func(t *testing.T) {
		request, _ := http.NewRequest(http.MethodGet, "/healthz", nil)
		response := httptest.NewRecorder()

		Health(response, request)

		got := response.Body.String()
		want := "test"

		gotStatus := response.Code
		wantStatus := http.StatusOK

		if got != want {
			t.Errorf("got %q, want %q", got, want)
		}

		if gotStatus != wantStatus {
			t.Errorf("got %d, want %d", gotStatus, wantStatus)
		}
	})
}
