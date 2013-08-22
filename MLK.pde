//http://blog.blprnt.com/blog/blprnt/updated-quick-tutorial-processing-twitter

import java.util.Date;

//the image stuff
float fontSizeMax = 20;
float fontSizeMin = 10;
float spacing = 12;
float kerning = 0.5;
boolean fontSizeStatic = false;
boolean blackAndWhite = false; 
PFont font;
PImage img;
float x = 0;
float y = 10;


//The twitter stuff
ArrayList<String> tweets = new ArrayList();
FilterQuery fq = new FilterQuery();
String keywords[] = {
  "chelsea manning"
};

String tweet;
boolean tweetLoaded;

void setup() {
  size(533, 769);
  background(0);
  smooth();

  //image stuff
  font = createFont("Times", 10);
  img = loadImage("pic.png");



  //OAuth Credentials
  ConfigurationBuilder cb = new ConfigurationBuilder();
  cb.setOAuthConsumerKey("muBHyzsmbgb0Aa9xjXF0wg");
  cb.setOAuthConsumerSecret("bJ97B7PdGY46amtEhvzzN9vH2XhyvxRmzDggxFfKvc");
  cb.setOAuthAccessToken("16931374-TusvFdBgBKYp8Nn1zvKN0X1daxuMu51FrO7Z39u0U");
  cb.setOAuthAccessTokenSecret("EyR8cLkaRtFxwM90dct5ZDU89JtlMjJSqkTskdLHg");

  //Make Twitter Stream and query
  TwitterStream twitter = new TwitterStreamFactory(cb.build()).getInstance();
  twitter.addListener(listener);
  if (keywords.length==0) {
    twitter.sample();
  } 
  else {
    twitter.filter(fq.track(keywords));
  }
}

void draw() {
  fill(0, 1);
  //rect(0, 0, width, height);
}

void drawTweet() {
  textAlign(255);
  int counter = 0;
  int charPos = 0;

  while (charPos < tweet.length ()) {
    int imgX = (int) map(x, 0, width, 0, img.width);
    int imgY = (int) map(y, 0, height, 0, img.height);
    //get current color:
    color c = img.pixels[imgY*img.width + imgX];
    int greyscale = round(red(c)*0.222 + green(c)*0.707 + blue(c)*0.071);

    pushMatrix();
    translate(x, y);

    if (fontSizeStatic) {
      textFont(font, fontSizeMax);
      if (blackAndWhite) fill(greyscale);
      else fill(c);
    } 
    else {
      // greyscale to fontsize
      float fontSize = map(greyscale, 0, 255, fontSizeMax, fontSizeMin);
      fontSize = max(fontSize, 1);
      textFont(font, fontSize);
      if (blackAndWhite) fill(0);
      else fill(c);
    }

    char letter = tweet.charAt(counter);
    text(letter, 0, 0);
    float letterWidth = textWidth(letter) + kerning;
    // for the next letter ... x + letter width
    x = x + letterWidth; // update x-coordinate
    popMatrix();

    // linebreaks
    if (x+letterWidth >= width) {
      x = 0;
      y = y + spacing; // add line height
    }

    counter++;
    charPos++;
    if (counter > tweet.length()-1) counter = 0;


    //  fill(255, random(50, 150));
    //  textSize(10);
    //  int x = int(random(width-textWidth(tweet)));
    //  text(tweet, x, random(height), width, height);
  }
}


void keyReleased() {
  // change render mode
  if (key == '1') fontSizeStatic = !fontSizeStatic;
  // change color stlye
  if (key == '2') blackAndWhite = !blackAndWhite;
  println("fontSizeMin: "+fontSizeMin+"  fontSizeMax: "+fontSizeMax+"   fontSizeStatic: "+fontSizeStatic+"   blackAndWhite: "+blackAndWhite);
}

void keyPressed() {
  // change fontSizeMax with arrowkeys up/down 
  if (keyCode == UP) fontSizeMax += 2;
  if (keyCode == DOWN) fontSizeMax -= 2; 
  // change fontSizeMin with arrowkeys left/right
  if (keyCode == RIGHT) fontSizeMin += 2;
  if (keyCode == LEFT) fontSizeMin -= 2; 

  //fontSizeMin = max(fontSizeMin, 2);
  //fontSizeMax = max(fontSizeMax, 2);
}



StatusListener listener = new StatusListener() {
  public void onStatus(Status status) {

    if (status.getText() != null) {
      tweet = status.getText();
      println(status.getText());
      drawTweet();
      tweetLoaded = true;
    } 
    else { 
      tweetLoaded = false;
    }
  }

  public void onDeletionNotice(StatusDeletionNotice statusDeletionNotice) {
    System.out.println("Got a status deletion notice id:" + statusDeletionNotice.getStatusId());
  }

  public void onTrackLimitationNotice(int numberOfLimitedStatuses) {
    System.out.println("Got track limitation notice:" + numberOfLimitedStatuses);
  }

  public void onScrubGeo(long userId, long upToStatusId) {
    System.out.println("Got scrub_geo event userId:" + userId + " upToStatusId:" + upToStatusId);
  }

  public void onStallWarning(StallWarning stallWarning) {
    System.out.println("Got a stall warning: " + stallWarning.getMessage() + " Percent Full: " + stallWarning.getPercentFull());
  }

  public void onException(Exception ex) {
    ex.printStackTrace();
  }
};

