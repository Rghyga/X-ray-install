package main
import ("bufio";"fmt";"os";"regexp";"sort")
type Pair struct { User string; Count int }
func main(){ f,err:=os.Open("/var/log/xray/access.log"); if err!=nil { fmt.Println("cannot open access log"); return }; defer f.Close(); re:=regexp.MustCompile(`email: ([^ ]+)`); m:=map[string]int{}; s:=bufio.NewScanner(f); for s.Scan(){ x:=re.FindStringSubmatch(s.Text()); if len(x)>=2 { m[x[1]]++ } }; arr:=make([]Pair,0,len(m)); for u,c:=range m { arr=append(arr,Pair{u,c}) }; sort.Slice(arr,func(i,j int) bool { return arr[i].Count>arr[j].Count }); fmt.Println("TOP USER TRAFFIC (request-based)"); fmt.Println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━"); max:=10; if len(arr)<max { max=len(arr) }; for i:=0;i<max;i++ { fmt.Printf("%d. %-20s %d\n", i+1, arr[i].User, arr[i].Count) } }
