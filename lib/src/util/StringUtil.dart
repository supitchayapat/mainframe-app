class StringUtil {
  /** Camelizes the given string.
   * For example, `background color' => `backgroundColor`.
   *
   * Note: for better performance, it assumes there must be a character following a dash.
   */
  static String camelize(String name) {
    StringBuffer sb;
    int k = 0;
    for (int i = 0, len = name.length; i < len; ++i) {
      if (name[i] == '-' || name[i] == ' ') {
        if (sb == null) sb = new StringBuffer();
        String sub = name.toLowerCase().substring(k, i+1);
        if(sb.isEmpty) {
          if(sub[0] == "(")
            sub = sub[0] + sub[1].toUpperCase() + sub.substring(2);
          else
            sub = sub[0].toUpperCase() + sub.substring(1);
        }
        sb..write(sub)..write(name[++i].toUpperCase());
        k = i + 1;
      }
    }
    return sb != null ? (sb..write(name.substring(k).toLowerCase())).toString() : name;
  }
}