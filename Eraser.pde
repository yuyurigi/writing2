class Eraser {
  int drawLine;
  int ellipseSize = 28; //消しゴムの大きさ;
  float x, y, eY, startY, goalY, firstX, lastX, lineHeight;
  PVector location; //消しゴムの中心位置を格納する変数
  PVector velocity = new PVector(-2, 8); //消しゴムの速度を格納する変数
  //２番目の数値を大きくすると消すスピードが早くなる;
  PGraphics pg;
  int num;

  Eraser(int _drawLine) {
    lineHeight = textSize*0.6;
    pg = createGraphics(width, int(textSize*2));

    drawLine = _drawLine;
    setFirstX();

    x = 0;
    y = textY-textSpace;
    location = new PVector(firstX, 30);
  }

  void setFirstX() {
    if (lineIndex>0) {

      if (grp.get(currentLine).countChildren() == 0) {
        firstX = textX + 100;
      } else {
        firstX = textX+texts.get(texts.size()-1).currentX;
        if (firstX+ellipseSize/2 > rrX+rrWidth) { //消しゴムの最初の位置がウィンドウよりはみ出るとき
          firstX = rrX+rrWidth-ellipseSize; //はみ出ない位置に設定する
        }
      }
      
    } else { //テキストがない状態で消しゴムモードに入ったとき
      firstX = textX + 100;
    }
  }

  void setNum(int _num) {
    num = _num;
  }

  void display() {
    pushMatrix();
    translate(x, y);
    location.add(velocity);
    pushMatrix();
    translate(textX, textSpace);
    if (bGuide) {
      fill(231, 35, 133); //文字の色をピンクにする
    } else {
      fill(textColor);
    }
    if (lineIndex>0) { //テキストがあるとき
      RShape[] splitShapes = grp.get(drawLine).split(1);
      RG.shape(splitShapes[0]);
    }
    popMatrix();
    pg.beginDraw();
    if (bGuide) {
      pg.fill(248, 171, 30); //消しゴムの色をオレンジにする
    } else {
      pg.fill(255, 255, 255);
    }
    pg.noStroke();
    pg.ellipse(location.x, location.y, ellipseSize, ellipseSize);
    pg.endDraw();
    image(pg, 0, 0);
    if (bGuide) {
      fill(255, 0, 0);
      text(num, 50, 10);
    }
    popMatrix();
    if (location.y < 30 || location.y > 30+lineHeight) { //上・下にあたったら逆方向に動く
      velocity.y = velocity.y * -1;
    }
    if (location.y < 30) { //上にあたったとき
      velocity.x = -velocity.x * 2.5;
    }
    if (location.y > 30+lineHeight) { //下にあたったとき
      velocity.x = 2;
    }
    if (location.x < textX) {
      velocity.x = 0;
      velocity.y = 0;
    }
  }

  void setVelocity(float vx, float vy) {
    velocity.x = vx;
    velocity.y = vy;
  }

  //改行-----------------------------------
  void setEasing(float _startY, float _goalY) {
    eY = 0;
    startY = _startY;
    goalY = _goalY;
  }

  void move(float speed) {
    y = map(easeInOutBack(eY), 0, 1, startY, goalY);
    eY += 1 / speed; //イージングのスピード（数値が小さいほど早い）
    if (eY > 1) {
      eY = 1;
      y = goalY;
    }
  }
}
