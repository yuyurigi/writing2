//文字スピード調整

import geomerative.*;
import java.util.Calendar;
import java.util.Iterator;

//swing
import javax.swing.*;
import java.awt.*;
import javax.swing.border.LineBorder;
import java.awt.Font;

boolean bGuide = false; //ガイドの表示

ArrayList<RShape> grp = new ArrayList<RShape>();
int textSize = 60; //一文字の大きさ
int currentLine = 0;
int time = 0; //文字に使う値
int aniTime = 0; //キャラのアニメーション用タイム
int textSpace = 65; //行間
int bodyFrame = 0; //現在のキャラのフレーム
int eyeFrame = 0; //現在の目のフレーム
int currentFrame = 0;
int lineIndex = 0; //四角形の中で何行目か
int wink, newLineNum, currentNewLine, lineNum;
int mode = 10; //0:テキストを書く 1:改行
//2:上目（そのあと消しゴム） 3:ペンと消しゴムを入れ替える 4:文字を消す 5:消しゴムとペンを入れ替える
//6:改行（マイナス）
//7:上目
//8:上目（そのあとページめくり） 9:ページめくる　
//10:静止モード
int prevMode; //１フレーム前のmodeの値
int eraserCount = 0; //消しゴムかけてる時間
ArrayList<Integer> intervals = new ArrayList<Integer>();
ArrayList<Float> lineWidths = new ArrayList<>();
float textX, textY, imageX, imageY, rrX, rrY, rrHeight;
float padding = 50; //四角形と文字の間のパディング
float rrWidth = 718; //四角形の幅
float div = 1.7; //文字を書くスピード
ArrayList<String> lines = new ArrayList<String>();
String[] emojis;
String imageName = "images[0]";
String fontName = "APJapanesefont.ttf";
PFont textFont;
PImage[] images = new PImage[26];
PImage[] eyes = new PImage[7];
PImage mouseCursor, handCursor;
boolean bEye = false;
boolean prevbEye; //１フレーム前のbEyeの値
boolean bEndAddLine = false;
ArrayList<Text> texts = new ArrayList<Text>();
ArrayList<RoundRect> rrect = new ArrayList<RoundRect>();
ArrayList<Integer> textNum = new ArrayList<Integer>(); //四角形の中にテキストが何行おさまってるか
FloatList textCurrentY = new FloatList();
ArrayList<Eraser> erasers = new ArrayList<Eraser>();
color textColor = color(67, 59, 55);


//文字入力部分
JLayeredPane pane;
JTextArea area;
PShape sPencil;
PShape sEraser;
PShape sFile;
PVector[] svgPos = new PVector[3];
int svgSize = 55;
int svgSize_small;
color[] butCol = new color[3];
color[] svgCol = new color[3];
color infoBackColor, buttonColor, buttonColor2, svgColor, svgColor2, infoColor, infoTextColor;
int tfHeight, infoPadding, infoTextSize;
String[] infoText = new String[3];
float[] infoWidth = new float[3];
boolean[] bInfo = new boolean[3];
PFont infoFont;

void setup() {
  size(1080, 750);
  frameRate(60);
  smooth();

  //geomerative
  RG.init(this);

  //ガイド用のフォント
  textFont = createFont("Kodchasan-Medium.ttf", 28);

  //画像をロード
  //キャラ
  for (int i = 0; i < images.length; i++) {
    String imageName = "ani-" + nf(i, 1) + ".png";
    images[i] = loadImage(imageName);
  }
  //目
  for (int i = 0; i < eyes.length; i++) {
    String imageName = "eye-" + nf(i, 1) + ".png";
    eyes[i] = loadImage(imageName);
  }

  //画像の位置
  imageX = width-images[0].width-20;
  imageY = height-images[0].height-10-142;
  //テキストのy位置
  textX = 80;
  textY = height-90-142;

  //四角形を追加
  rrX = textX-padding;
  rrY = textY-textSpace-padding;
  rrHeight = textSpace*2+padding*2;
  rrect.add(new RoundRect(rrX, rrY, rrWidth, rrHeight));

  //文字入力部分
  textField();
}

void draw() {
  //背景------------------------------------------------------------
  background(#4f9495); //背景

  //キャラ----------------------------------------------------------
  image(images[bodyFrame], imageX, imageY);
  if (prevMode != mode) aniTime = 0;

  //画像が切り替わるスピードを調整
  int frame;
  if (mode==4 && mode==12) {
    frame = aniTime % 5; //消しゴム（早くする）
  } else {
    frame = aniTime % 10;
  }

  if (mode == 0) { //テキストの描画をしてるときだけ動く
    if (frame == 1) {
      bodyFrame = int(random(3));
    }
  }

  if (mode == 3) { //ペンから消しゴムに持ち替え
    if (bodyFrame < 13 && frame == 1) {
      bodyFrame+=1;
    }
    if (bodyFrame == 13) {
      //ペンから消しゴムに持ち替える動作が終わったらモード変更
      if (lineIndex==0) {
        mode = 4;
      } else {
        mode = 6;
      }
      bodyFrame = 14; //キャラの画像を変更
      eyeFrame = 0; //目の画像を変更
    }
  }

  if (mode == 4) { //消しゴム
    if (frame == 1) {
      bodyFrame = int(random(13, 16));
    }
  }

  if (mode == 5) { //消しゴムとペンを入れ替える
    if (bodyFrame > 3 && frame == 1) {
      bodyFrame-=1;
    }
    if (bodyFrame == 3) {
      mode = 10; //最初に戻る
      bodyFrame = 2;
      eyeFrame = 0;
    }
  }

  if (mode == 9 || mode == 16) { //ページめくる
    if (bodyFrame < 26 && frame == 1) {
      if (bodyFrame < 16) {
        bodyFrame=16;
      } else {
        bodyFrame+=1;
      }
    }

    if (bodyFrame > 25 && bEndAddLine == true) {
      mode = 0; //モード変更
      bodyFrame = 0;
      eyeFrame = 0;
      bEndAddLine = false;
    }
  }

  if (mode == 10) { //静止モード
    bodyFrame = 0;
  }

  //目--------------------------------------------------------------
  image(eyes[eyeFrame], imageX, imageY);
  if (mode == 0 || mode == 1 || mode == 10) { //テキストを書く、改行、静止モード
    wink(0, 2); //0~2番目の目の画像を使用してウィンク
  }
  //消しゴム
  if (mode == 2) { //上目
    eyeFrame = 3; //3番目の目の画像を使用

    if (frameCount > currentFrame+1*60) { //少しの間、上目づかい(60はframeRate)
      //上目づかいのあと
      mode=3; //モード変更
      eyeFrame = 4; //目の画像を変更
      bodyFrame = 2; //キャラの画像を変更
    }
  } else if (mode == 3) { //ペンから消しゴムに持ち替え
    wink(4, 6); //4~6番目の目の画像を使用してウィンク
  } else if (mode == 4) { //消しゴム
    wink(0, 2); //0~2番目の目の画像を使用してウィンク
  } else if (mode == 5) { //消しゴムからペンに持ち替え
    wink(4, 6);
  }

  //上目
  if (mode == 7) {
    eyeFrame = 3; //3番目の目の画像を使用

    if (frameCount > currentFrame+1*60) { //少しの間、上目づかい(60はframeRate)
      //上目づかいのあと
      mode=0; //モード変更
      eyeFrame = 0; //目の画像を変更
    }
  }

  //ページめくり
  if (mode == 8) { //上目
    eyeFrame = 3; //3番目の目の画像を使用

    if (frameCount > currentFrame+1*60) { //少しの間、上目づかい(60はframeRate)
      //上目づかいのあと
      mode=9; //モード変更
      eyeFrame = 0; //目の画像を変更
      bodyFrame = 16; //キャラの画像を変更
    }
  } else if (mode == 9) { //ページめくり
    wink(0, 2);
  }

  //四角形の描画----------------------------------------------------
  for (int i = 0; i < rrect.size(); i++) {
    rrect.get(i).display();
  }

  //テキスト-------------------------------------------------------
  if (mode == 0) {
    if (grp.get(currentLine).countChildren() == 0) mode = 1; //文字が空白のときは改行
  }

  if (mode==0 && prevMode==5) {
    //消しゴムかけた後のテキスト
    float currentX = erasers.get(erasers.size()-1).location.x-textX-textSize*1.3;
    if (currentX < 0) currentX = 0;
    float spPos = currentX / lineWidths.get(currentLine);
    time = int(map(spPos, 0, 1, 0, intervals.get(currentLine)-1));
  }

  //消しゴム-------------------------------------------------------

  if (mode==4 && prevMode!=4) {
    if (lineIndex==0) {
      erasers.add(new Eraser(currentLine));
    }
    if (bGuide) erasers.get(erasers.size()-1).setNum(erasers.size()-1);
  } else if (mode==4 && prevMode==4) {
    float eraserX = erasers.get(erasers.size()-1).location.x;
    if (eraserX<textX) { //消しゴムが最初の行の頭まで来たら
      if (lineIndex>0) {
        deleteText(); //最後のテキストを削除
      }
      changeMode5();
    }
  }


  //消しゴムとテキストの表示-----------------------------------------
  for (int i = 0; i < erasers.size()-1; i++) {
    erasers.get(i).display();
  }
  if (mode!=4 && mode!=5 && mode!=6 && mode!=12 && mode!=13) {
    if (erasers.size()>0) erasers.get(erasers.size()-1).display();
  }

  //テキスト
  pushMatrix();
  translate(textX, textY);
  if (texts.size()>0) {
    for (int i = 0; i < texts.size(); i++) {
      texts.get(i).display(); //テキスト表示
    }
  }
  popMatrix();

  if (mode==4 || mode==5 || mode==6) { //消しゴム時、[テキスト　消しゴム]の順
    if (erasers.size()>0) erasers.get(erasers.size()-1).display(); //現在の消しゴムを表示
  }

  //time---------------------------------------------------------
  if (mode == 0) { //文章を書いてるとき
    time++;
  } else if (mode==4) { //消しゴム
    eraserCount++;
  }

  if (mode==0 && time%intervals.get(currentLine)==0) { //１文書き終わったとき
    time = 0;
    mode = 1; //改行
  }

  if (mode==1) {
    addLine(); //改行
  }

  if (mode==6) {
    minusLine(); //改行（マイナス）
  }

  if (mode==9) { //ページめくり
    newPage(); //改行
    time = 0;
  }

  prevMode = mode;
  prevbEye = bEye;
  aniTime++;

  //文字入力スペース-----------------------------------------------
  fill(infoBackColor);
  rect(0, height-tfHeight, width, tfHeight);

  noStroke();
  fill(butCol[0]);
  rectMode(CENTER);
  rect(svgPos[0].x, svgPos[0].y, svgSize, svgSize, 10);
  fill(butCol[1]);
  rect(svgPos[1].x, svgPos[1].y, svgSize, svgSize, 10);
  fill(butCol[2]);
  rect(svgPos[2].x, svgPos[2].y, svgSize, svgSize, 10);
  rectMode(CORNER);
  fill(svgCol[0]);
  shape(sPencil, svgPos[0].x, svgPos[0].y, svgSize_small, svgSize_small);
  fill(svgCol[1]);
  shape(sEraser, svgPos[1].x, svgPos[1].y, svgSize_small, svgSize_small);
  fill(svgCol[2]);
  shape(sFile, svgPos[2].x, svgPos[2].y, svgSize_small, svgSize_small);

  rectMode(CORNER);
  textFont(infoFont);
  textAlign(CENTER, TOP);
  if (bInfo[0] == true) {
    fill(infoColor);
    rect(mouseX+10, mouseY, infoWidth[0], infoTextSize+infoPadding*2, 10);
    fill(infoTextColor);
    text(infoText[0], mouseX+10+infoWidth[0]/2, mouseY+infoPadding*0.8);
  }
  if (bInfo[1] == true) {
    fill(infoColor);
    rect(mouseX+10, mouseY, infoWidth[1], infoTextSize+infoPadding*2, 10);
    fill(infoTextColor);
    text(infoText[1], mouseX+10+infoWidth[1]/2, mouseY+infoPadding*0.8);
  }
  if (bInfo[2] == true) {
    fill(infoColor);
    rect(mouseX-10-infoWidth[2], mouseY, infoWidth[2], infoTextSize+infoPadding*2, 10);
    fill(infoTextColor);
    text(infoText[2], mouseX-10-infoWidth[2]/2, mouseY+infoPadding*0.8);
  }

  //マウスオーバー時
  mouseOver();


  //ガイド----------------------------------------------------------

  if (bGuide) {
    textFont(textFont);
    textAlign(LEFT, TOP);
    fill(0);
    text("mode:"+mode, width-400, 300); //現在のモード番号を画面に表示
    text("prevMode:"+prevMode, width-450, 340);

    text("currentLine:"+currentLine, 30, 60);
    text("rrect.size:" + rrect.size(), 30, 90);
    text("texts.size:" + texts.size(), 30, 120);
    text("bodyFrame:" + bodyFrame, 30, 150);
    text("textNum:" + textNum, 30, 180);
    text("erasers.size:" + erasers.size(), 30, 210);
    text("lineIndex:" + lineIndex, 30, 240);
    text("lineNum:" + lineNum, 30, 270);
    text("lines.size:" + lines.size(), 30, 300);
  }
}

//目のまばたき-------------------------------------------------------
void wink(int first, int end) {
  int space = int(random(80, 150)); //まばたきするタイミング（ランダム）
  int frame2 = frameCount % space;
  if (frame2 == space-1) {
    bEye = true; //まばたきを有効にする
  }
  if (bEye) {
    if (bEye != prevbEye) {
      wink = 0; //まばたきに使う数値
    }
    //まばたきのスピード
    if (wink%4 == 3) {
      eyeFrame += 1;
    }
    if (eyeFrame == end+1) { //まばたき終了
      eyeFrame = first;
      bEye = false;
    }
  }
  wink++;
}

//モード５に変更------------------------------------------------------
void changeMode5() {
  //消しゴムを止める
  erasers.get(erasers.size()-1).setVelocity(0, 0);

  deleteEraser();

  if (lineIndex>0) {
    lineIndex-=1;
  }

  mode = 5; //モード変更
  bodyFrame = 13;
  eyeFrame = 4;
  eraserCount = 0;
}

//マウスオーバー------------------------------------------------
void mouseOver() {
  if (mode == 10) {
    if (svgPos[0].x-svgSize/2 < mouseX && mouseX < svgPos[0].x+svgSize/2 &&
      svgPos[0].y-svgSize/2 < mouseY && mouseY < svgPos[0].y+svgSize/2 && mode==10) {
      butCol[0] = color(buttonColor2); //ボタンの色を変える
      svgCol[0] = color(svgColor2);
      bInfo[0] = true;
    } else {
      butCol[0] = color(buttonColor);
      svgCol[0] = color(svgColor);
      bInfo[0] = false;
    }

    if (svgPos[1].x-svgSize/2 < mouseX && mouseX < svgPos[1].x+svgSize/2 &&
      svgPos[1].y-svgSize/2 < mouseY && mouseY < svgPos[1].y+svgSize/2 && mode==10) {
      butCol[1] = color(buttonColor2); //ボタンの色を変える
      svgCol[1] = color(svgColor2);
      bInfo[1] = true;
    } else {
      butCol[1] = color(buttonColor);
      svgCol[1] = color(svgColor);
      bInfo[1] = false;
    }

    if (svgPos[2].x-svgSize/2 < mouseX && mouseX < svgPos[2].x+svgSize/2 &&
      svgPos[2].y-svgSize/2 < mouseY && mouseY < svgPos[2].y+svgSize/2 && mode==10) {
      butCol[2] = color(buttonColor2); //ボタンの色を変える
      svgCol[2] = color(svgColor2);
      bInfo[2] = true;
    } else {
      butCol[2] = color(buttonColor);
      svgCol[2] = color(svgColor);
      bInfo[2] = false;
    }

    //カーソル
    if (svgPos[0].x-svgSize/2 < mouseX && mouseX < svgPos[0].x+svgSize/2 &&
      svgPos[0].y-svgSize/2 < mouseY && mouseY < svgPos[0].y+svgSize/2 && mode==10) {
      cursor(HAND);
    } else if (svgPos[1].x-svgSize/2 < mouseX && mouseX < svgPos[1].x+svgSize/2 &&
      svgPos[1].y-svgSize/2 < mouseY && mouseY < svgPos[1].y+svgSize/2 && mode==10) {
      cursor(HAND);
    } else if (svgPos[2].x-svgSize/2 < mouseX && mouseX < svgPos[2].x+svgSize/2 &&
      svgPos[2].y-svgSize/2 < mouseY && mouseY < svgPos[2].y+svgSize/2 && mode==10) {
      cursor(HAND);
    } else {
      cursor(ARROW);
    }
  }//if (mode == 10) - end

  if (mode != 10) {
    for (int i = 0; i < svgPos.length; i++) {
      bInfo[i] = false;
    }
    cursor(ARROW);
  }
}
//マウス押した時のイベント---------------------------------------------
void mousePressed() {
  //Pencil
  if (svgPos[0].x-svgSize/2 < mouseX && mouseX < svgPos[0].x+svgSize/2 &&
    svgPos[0].y-svgSize/2 < mouseY && mouseY < svgPos[0].y+svgSize/2 && mode==10) {
    butCol[0] = color(buttonColor2); //ボタンの色を変える
    svgCol[0] = color(svgColor2);
    loadText(area.getText()); //テキストボックスの文字をロード
    area.setText(""); //テキストボックスの中のテキストをクリアする
    texts.add(new Text(currentLine)); //テキストを追加
    mode = 0;
  }

  //eraser
  if (svgPos[1].x-svgSize/2 < mouseX && mouseX < svgPos[1].x+svgSize/2 &&
    svgPos[1].y-svgSize/2 < mouseY && mouseY < svgPos[1].y+svgSize/2 && mode==10) {
    butCol[1] = color(buttonColor2); //ボタンの色を変える
    svgCol[1] = color(svgColor2);
    mode = 2;
    currentFrame = frameCount;
  }

  //new note
  if (svgPos[2].x-svgSize/2 < mouseX && mouseX < svgPos[2].x+svgSize/2 &&
    svgPos[2].y-svgSize/2 < mouseY && mouseY < svgPos[2].y+svgSize/2 && mode==10) {
    butCol[2] = color(buttonColor2); //ボタンの色を変える
    svgCol[2] = color(svgColor2);
    deleteEraser(); //現在の行にEraserがあるときは消す
    mode = 8;
    currentFrame = frameCount;
  }
}

//テキストの削除------------------------------------------------------
void deleteText() {
  int num = texts.size()-1;
  texts.remove(num); //最後のテキストを削除
  lines.remove(num);
  lineWidths.remove(num);
  intervals.remove(num);
}

//消しゴムの削除------------------------------------------------------
void deleteEraser() {
  //現在の行にEraserがあるときは消す
  if (erasers.size()>0) {
    if (erasers.get(erasers.size()-1).y == textY-textSpace) {
      erasers.remove(erasers.size()-1);
      if (lineIndex>0) grp.remove(grp.size()-1);
    }
  }
}

//キーを押した時のイベント---------------------------------------------
void keyPressed() {
  if (key == 's' || key == 'S')saveFrame(timestamp()+"_####.png");
}

String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}
