module CompileTimeString {
  proc substr(param str: string, param start: int, param len: int) param {
    if str.size < start + len then compilerError("Substring out of bounds");
    if len <= 0 then return "";

    return str[start] + substr(str, start+1, len-1);
  }

  proc occurrences(param str: string, param pat: string, param idx: int = 0) param {
    for param i in idx..<(str.size-pat.size) {
      if substr(str, i, pat.size) == pat {
        return 1 + occurrences(str, pat, i+1);
      }
    }
    return 0;
  }

  proc find(param str: string, param pat: string, param ith=0, param startAt=0) param {
    // Find the ith occurrence of pat in str starting from the beginning
    for param i in startAt..<(str.size-pat.size) {
      if substr(str, i, pat.size) == pat {
        if ith == 0 then return i;
        return find(str, pat, ith-1, i+1);
      }
    }
    return -1;
  }

  proc split(param str: string, param pat: string, param ith=0) param {
    if ith == 0 {
      param end = find(str, pat);
      return if end == -1 then str else substr(str, 0, end);
    } else {
      param sep = find(str, pat);
      if sep == -1 then compilerError("not enough occurrences of separator");
      param newStart = sep + pat.size;
      param newStr = substr(str, newStart, str.size-newStart);
      compilerWarning("newStart: ", newStr);
      return split(newStr, pat, ith-1);
    }
  }
  proc main() {
    param s = "real(32),real(64)";
    param nTypes = occurrences(s, ",") + 1;
    compilerWarning(nTypes:string);
    for param i in 0..#nTypes {
      param t = split(s, ",", i);
      compilerWarning("'" + t:string + "'");
    }
  }

}
