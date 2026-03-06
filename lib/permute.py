#!/usr/bin/env python3
import sys
import os

def sorted_letters(word):
    """Return sorted letters of a word as a string."""
    return ''.join(sorted(word))

def main():
    if len(sys.argv) != 2:
        print("Usage: permute <word>", file=sys.stderr)
        sys.exit(1)
    
    input_word = sys.argv[1]
    sorted_input = sorted_letters(input_word)
    
    # Read from ~/slowa.txt
    slowa_path = os.path.expanduser('~/slowa.txt')
    
    try:
        with open(slowa_path, 'r', encoding='utf-8') as f:
            for line in f:
                word = line.strip()
                if not word:
                    continue
                sorted_word = sorted_letters(word)
                if sorted_input == sorted_word:
                    print(word)
    except FileNotFoundError:
        print(f"Error: {slowa_path} not found", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == '__main__':
    main()
