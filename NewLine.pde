//改行(1行）--------------------------------------------------------------
void addLine() {
  if (mode != prevMode) {
    texts.get(texts.size()-1).setBool(false); //今書いた文は描画中の文でなくなる
    currentLine+=1;
    lineIndex+=1;

    for (int i = 0; i < texts.size(); i++) {
      float currentY = texts.get(i).y;
      float newY = currentY-textSpace;
      //イージングで使う値
      texts.get(i).setEasing(currentY, newY);
    }
    //四角形
    for (int i = 0; i < rrect.size(); i++) {
      float currentY = rrect.get(i).y;
      float newY = currentY-textSpace;
      rrect.get(i).setEasing(currentY, newY);
    }
    //消しゴム
    Iterator<Eraser> it = erasers.iterator(); //いらない消しゴムは消す
    while (it.hasNext()) {
      float currentY = it.next().y;
      if (currentY == textY-textSpace) {
        it.remove();
      }
    }

    for (int i = 0; i < erasers.size(); i++) { //いる消しゴムは残して改行
      float currentY = erasers.get(i).y;
      float newY = currentY-textSpace;
      erasers.get(i).setEasing(currentY, newY);
    }
  }

  //イージングを使って改行する
  for (int i = 0; i < texts.size(); i++) { //テキスト
    texts.get(i).move(50.00);
  }
  for (int i = 0; i < rrect.size(); i++) { //四角形
    rrect.get(i).move(50.00);
  }

  for (int i = 0; i < erasers.size(); i++) {
    erasers.get(i).move(50.0);
  }

  //改行を終わらせる
  if (texts.get(0).eY == 1) {

    //新しい行を追加
    if (currentLine!= lines.size()) {
      texts.add(new Text(currentLine));
      mode = 0;
    } else {
      bEndAddLine = true;
      mode = 10;
    }

    //画面外のテキストと四角形は削除
    deleteTextandRect();
  } //end--if (texts.get(0).getEY()==1)
} //end--addLine()

//ページめくり-----------------------------------------------------------------------
void newPage() {
  if (mode != prevMode) {

    if (texts.size()>0) {

      for (int i = 0; i < texts.size(); i++) {
        float currentY = texts.get(i).y;
        float newY = currentY-textSpace*2;
        //イージングで使う値
        texts.get(i).setEasing(currentY, newY);
      }
    }

    rrect.get(rrect.size()-1).rheight = textSpace*(lineIndex)+padding*2;
    textNum.add(lineIndex); //文を何行書いてるか格納
    lineIndex = 0;

    //新しい四角形を追加
    rrect.add(new RoundRect(rrX, rrY+textSpace*2, rrWidth, rrHeight));

    //四角形
    for (int i = 0; i < rrect.size(); i++) {
      float currentY = rrect.get(i).y;
      float newY = currentY-textSpace*2;
      rrect.get(i).setEasing(currentY, newY);
    }
    //消しゴム
    for (int i = 0; i < erasers.size(); i++) {
      float currentY = erasers.get(i).y;
      float newY = currentY-textSpace*2;
      erasers.get(i).setEasing(currentY, newY);
    }
  }


  //イージングを使って改行する
  if (texts.size()>0) {
    for (int i = 0; i < texts.size(); i++) { //テキスト
      texts.get(i).move(86.00); //move()の中の数字、小さいほど早い
    }
  }

  for (int i = 0; i < rrect.size(); i++) { //四角形
    rrect.get(i).move(86.00);
  }

  for (int i = 0; i < erasers.size(); i++) {
    erasers.get(i).move(86.0); //消しゴム
  }

  //改行を終わらせる
  if (rrect.get(0).eY == 1) {

    bEndAddLine = true;

    deleteTextandRect();

    mode = 10;
    //}
  } //end--if (texts.get(0).getEY()==1)
}

//画面外のテキストと四角形と消しゴムを削除---------------------------------
void deleteTextandRect() {
  if (currentLine==0 && rrect.size()>2) {
    float rrBottomY = rrect.get(0).y + rrect.get(0).rheight;
    if (rrBottomY < 0) {
      int deleteText = textNum.get(0);
      texts.subList(0, deleteText).clear(); //テキストを削除
      lines.subList(0, deleteText).clear();
      grp.subList(0, deleteText).clear();
      lineWidths.subList(0, deleteText).clear();
      intervals.subList(0, deleteText).clear();
      currentLine = currentLine-deleteText;
      rrect.remove(0); //四角形を削除
      textNum.remove(0);
    }

    //消しゴムを削除
    Iterator<Eraser> it = erasers.iterator();
    while (it.hasNext()) {
      float currentY = it.next().y;
      if (currentY < 0) {
        it.remove();
      }
    }
  }
}

//改行（マイナス）----------------------------------------------------
void minusLine() {
  if (mode != prevMode) {

    for (int i = 0; i < texts.size(); i++) {
      float currentY = texts.get(i).y;
      float newY = currentY+textSpace;
      //イージングで使う値
      texts.get(i).setEasing(currentY, newY);
    }
    //四角形
    for (int i = 0; i < rrect.size(); i++) {
      float currentY = rrect.get(i).y;
      float newY = currentY+textSpace;
      rrect.get(i).setEasing(currentY, newY);
    }

    for (int i = 0; i < erasers.size(); i++) {
      float currentY = erasers.get(i).y;
      float newY = currentY+textSpace;
      erasers.get(i).setEasing(currentY, newY);
    }
  }

  //イージングを使って改行する
  for (int i = 0; i < texts.size(); i++) { //テキスト
    texts.get(i).move(50.0); //move(float speed) : speedの数値が小さいほど早い
  }
  for (int i = 0; i < rrect.size(); i++) { //四角形
    rrect.get(i).move(50.0);
  }
  for (int i = 0; i < erasers.size(); i++) { //消しゴム
    erasers.get(i).move(50.0);
  }

  //改行を終わらせる
  if (texts.get(0).eY==1) {
    currentLine-=1;

    if (bGuide) {
      if (erasers.size()>0) erasers.get(erasers.size()-1).setNum(erasers.size()-1);
    }

    erasers.add(new Eraser(currentLine));
    time=1;

    mode = 4;
  } //end--if (texts.get(0).getEY()==1)
} //end--minusLine()
