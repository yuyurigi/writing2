void textField() {
  infoBackColor = color(#9fc7b7); //背景色
  buttonColor = color(255); //ボタンの色
  buttonColor2 = color(79, 148, 149); //マウスオン時の色
  svgColor = color(79, 148, 149); //svgの色
  svgColor2 = color(255); //マウスオン時の色
  infoColor = color(#286061);
  infoTextColor = color(255);

  tfHeight = 142; //テキストフィールドの高さ

  sPencil = loadShape("edit-pencil.svg");
  sPencil.disableStyle();
  sEraser = loadShape("eraser.svg");
  sEraser.disableStyle();
  sFile = loadShape("file-empty.svg");
  sFile.disableStyle();
  // SmoothCanvasの親の親にあたるJLayeredPaneを取得
  Canvas canvas = (Canvas) surface.getNative();
  pane = (JLayeredPane) canvas.getParent().getParent();
  // 複数行のテキストボックスを作成
  area = new JTextArea();
  area.setLineWrap(true); //画面端でテキストを折り返すように設定する
  area.setWrapStyleWord(true); //単語単位でテキストを折り返すようになる
  area.setFont(new Font("KiwiMaru-Regular", Font.PLAIN, 40));
  area.setForeground(new Color(67, 59, 55)); //テキストカラー
  area.setSelectedTextColor(new Color(67, 59, 55)); //選択したテキストの色
  area.setSelectionColor(new Color(201, 207, 241)); //選択領域をレンダリングするのに使う現在の色を設定します。
  JScrollPane scrollPane = new JScrollPane(area);
  scrollPane.setBounds((int)padding, height-tfHeight/2-svgSize/2, 730, svgSize);
  scrollPane.setBorder(new LineBorder(Color.WHITE, 1, false));
  pane.add(scrollPane);

  //svgの位置（中央）
  int space = (width-scrollPane.getX()-scrollPane.getWidth()-svgSize*3)/4;
  svgPos[0] = new PVector(scrollPane.getX()+scrollPane.getWidth()+svgSize/2+5, scrollPane.getY()+scrollPane.getHeight()/2);
  svgPos[2] = new PVector(width-padding-svgSize/2, svgPos[0].y);
  svgPos[1] = new PVector(svgPos[0].x+(svgPos[2].x-svgPos[0].x)/2, svgPos[0].y);
  svgSize_small = int(svgSize*0.6);
  shapeMode(CENTER);
  for (int i = 0; i < svgCol.length; i++) {
    svgCol[i] = color(255);
  }

  //svgにマウスオンしたときの説明文
  infoText[0] = "テキストを出力";
  infoText[1] = "１文消す";
  infoText[2] = "新しいページ";
  infoPadding = 5;
  infoTextSize = 17;
  infoFont = createFont("Corporate-Logo-Rounded.ttf", infoTextSize);
  textFont(infoFont);
  for (int i = 0; i < 3; i++) {
    infoWidth[i] = textWidth(infoText[i]+infoPadding*2);
    bInfo[i] = false;
  }
}
