class Chao extends Organizar {

  PImage imagemChao;
  Chao(int x, int y) {
    super(x, y);
    imagemChao = loadImage("chao.png");
  }

  void imprimirChao() {
    
    image(imagemChao, linha, coluna);
  }
}
