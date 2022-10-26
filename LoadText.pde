//テキストファイルから文章をロード＋長い文を分割--------------------------
void loadText(String _str) {
  String[] oriLines = split(_str, "\n");

  ArrayList<String> strList = new ArrayList<String>();
  PFont font = createFont(fontName, textSize);
  textFont(font);
  ArrayList<Integer> splitList = new ArrayList<Integer>();
  float lineWidth = rrWidth-padding*2;

  for (int i = 0; i < oriLines.length; i++) {
    float tw = 0;
    splitList.clear();
    for (int j = 0; j < oriLines[i].length(); j++) {
      char c1 = oriLines[i].charAt(j); //i番目の文字を取得
      float charWidth = textWidth(c1); //文字の幅を取得
      if (j == oriLines[i].length()-1) {
        if (c1 == '、' || c1 == '。') {
          charWidth = 0;
        }
      }
      tw += charWidth;
      if (tw > lineWidth) {
        splitList.add(j);
        tw = 0;
      }
    }
    int splitNum = splitList.size();
    if (splitNum==0) {
      strList.add(oriLines[i]);
    }
    String str;
    for (int k = 0; k < splitNum; k++) {
      int spl = splitList.get(k);
      if (splitNum == 1) {
        str = oriLines[i].substring(0, spl);
        strList.add(str);
        str = oriLines[i].substring(spl);
        strList.add(str);
      } else if (splitNum == 2) {
        if (k == 0) {
          str = oriLines[i].substring(0, spl);
          strList.add(str);
        } else {
          str = oriLines[i].substring(splitList.get(k-1), spl);
          strList.add(str);
          str = oriLines[i].substring(spl);
          strList.add(str);
        }
      } else {
        if (k == 0) {
          str = oriLines[i].substring(0, spl);
          strList.add(str);
        } else if (k == splitNum-1) {
          str = oriLines[i].substring(splitList.get(k-1), spl);
          strList.add(str);
          str = oriLines[i].substring(spl);
          strList.add(str);
        } else {
          str = oriLines[i].substring(splitList.get(k-1), spl);
          strList.add(str);
        }
      }
    }
  }

  //新しいテキストをlinesに追加
  for (int i = 0; i < strList.size(); i++) {
    lines.add(strList.get(i));
  }
  
  lineNum = strList.size(); //行数を取得

  int stringNum = strList.size();
  int first = lines.size()-stringNum; //ArrayList linesのどこから取得し始めるか

  for (int i = first; i < first+stringNum; i++) {
    grp.add(RG.getText(lines.get(i), fontName, textSize, LEFT)); //フォントをロード
  }

  //１文書く間隔（どの文の長さでも描画スピードを一定にする）
  for (int i = first; i < first+stringNum; i++) {
    //文の幅を取得
    float lineWidth2 = grp.get(i).getBottomRight().x - grp.get(i).getBottomLeft().x;
    lineWidths.add(lineWidth2);
    intervals.add(int(div*lineWidth2));
  }

  //四角形の高さを再設定
  rrect.get(rrect.size()-1).rheight = rrect.get(rrect.size()-1).rheight+(textSpace*lineNum);
}
