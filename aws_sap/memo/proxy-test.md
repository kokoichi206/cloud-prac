``` go
package main

import (
	"fmt"
	"net/http"
)

func handler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello, World")
}

func main() {
	http.HandleFunc("/hello", handler)
	http.ListenAndServe(":11111", nil)
}
```

``` sh
# 指定しないと 1080 port に向かってしまう。
curl -v localhost:8000/hello.txt --proxy http://192.168.0.113

curl -v localhost:8000/hello.txt --proxy http://192.168.0.113:8080


curl -v 'localhost:9999/api/v1/members' --proxy https://example.com:443


curl -v localhost:11111/hello --proxy http://192.168.0.113:8080
curl -v http://192.168.0.113:11111/hello --proxy http://192.168.0.113:8080

```
