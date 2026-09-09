class gerador extends Organizar {

  PImage imagemGerador;
  gerador(int x, int y) {
    super(x, y);
    imagemGerador = loadImage("gerador e removedor.png");
  }

  void imprimirGerador() {
    image(imagemGerador, linha, coluna);
  }
}
