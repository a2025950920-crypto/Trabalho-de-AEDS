class removedor extends Organizar {

  PImage imagemRemovedor;
  removedor(int x, int y) {
    super(x, y);
    imagemRemovedor = loadImage("gerador e removedor.png");
  }

  void imprimirRemovedor() {
    image(imagemRemovedor, linha, coluna);
  }
}
