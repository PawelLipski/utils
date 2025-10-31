#!/usr/bin/env bash
# Test regex matching performance across different languages
# Testing a pattern against a long string

PATTERN=".*xyz"
LENGTH=30000

echo "Testing regex pattern '$PATTERN' against ${LENGTH} 'a' characters"
echo "================================================================"
echo ""

echo "| Language/Tool | Time |"
echo "|---------------|------|"

# Re-run tests and capture output for markdown table
if command -v python3 >/dev/null 2>&1; then
  result=$(python3 -c "import re; import timeit; print(f'{timeit.timeit(lambda: re.search(\"$PATTERN\", \"a\" * $LENGTH), number=1) * 1000:.2f} ms')" 2>/dev/null)
  echo "| Python | $result |"
fi

if command -v javac >/dev/null 2>&1 && command -v java >/dev/null 2>&1; then
  echo "public class T { public static void main(String[] a) { long s = System.nanoTime(); java.util.regex.Pattern.compile(\"$PATTERN\").matcher(\"a\".repeat($LENGTH)).find(); System.out.printf(\"%.2f ms\\n\", (System.nanoTime() - s) / 1e6); }}" > /tmp/T.java && javac /tmp/T.java 2>/dev/null
  if [ $? -eq 0 ]; then
    result=$(java -cp /tmp T 2>/dev/null)
    echo "| Java | $result |"
  fi
fi

if command -v node >/dev/null 2>&1; then
  result=$(node -e "const s = Date.now(); /$PATTERN/.test('a'.repeat($LENGTH)); console.log(\`\${Date.now() - s} ms\`);" 2>/dev/null)
  echo "| JavaScript (Node.js) | $result |"
fi

if command -v perl >/dev/null 2>&1; then
  result=$(perl -e "use Time::HiRes qw(time); my \$s = time; 'a' x $LENGTH =~ /$PATTERN/; printf \"%.2f ms\n\", (time - \$s) * 1000;" 2>/dev/null)
  echo "| Perl | $result |"
fi

if command -v ruby >/dev/null 2>&1; then
  result=$(ruby -e "require 'benchmark'; t = Benchmark.measure { /$PATTERN/.match('a' * $LENGTH) }.real; puts \"#{(t * 1000).round(2)} ms\"" 2>/dev/null)
  echo "| Ruby | $result |"
fi

if command -v go >/dev/null 2>&1; then
  cat > /tmp/regex_perf.go <<EOF
package main
import ("fmt"; "regexp"; "strings"; "time")
func main() {
    s := time.Now()
    regexp.MustCompile("$PATTERN").MatchString(strings.Repeat("a", $LENGTH))
    fmt.Printf("%.2f ms", time.Since(s).Seconds() * 1000)
}
EOF
  result=$(go run /tmp/regex_perf.go 2>/dev/null)
  if [ $? -eq 0 ]; then
    echo "| Go | $result |"
  fi
fi

if command -v grep >/dev/null 2>&1; then
  result=$(printf '%s' "$(printf 'a%.0s' {1..$LENGTH})" | (time grep -q "$PATTERN") 2>&1 | grep real | awk '{print $2}' 2>/dev/null)
  if [ -n "$result" ]; then
    echo "| grep (basic) | $result |"
  fi
fi

if command -v grep >/dev/null 2>&1; then
  result=$(printf '%s' "$(printf 'a%.0s' {1..$LENGTH})" | (time grep -Eq "$PATTERN") 2>&1 | grep real | awk '{print $2}' 2>/dev/null)
  if [ -n "$result" ]; then
    echo "| grep -E (extended) | $result |"
  fi
fi

if command -v grep >/dev/null 2>&1 && echo | grep -P '' >/dev/null 2>/dev/null; then
  result=$(printf '%s' "$(printf 'a%.0s' {1..$LENGTH})" | (time grep -Pq "$PATTERN") 2>&1 | grep real | awk '{print $2}' 2>/dev/null)
  if [ -n "$result" ]; then
    echo "| grep -P (PCRE) | $result |"
  fi
fi
