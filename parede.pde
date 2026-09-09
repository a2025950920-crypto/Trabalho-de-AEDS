class parede extends Organizar {

  PImage imagemParede;
  parede(int x, int y) {
    super(x, y);
    imagemParede = loadImage("parede.png");
  }
  

  void imprimirParede() {
    
    image(imagemParede, linha, coluna);
  }
}
