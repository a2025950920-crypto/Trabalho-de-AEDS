final int LARGURA_JANELA = 930;
final int ALTURA_JANELA = 780;

final int MARGEM = 20;
final int ALTURA_CABECALHO = 100;
final int LARGURA_LEGENDA = 250;

char[][] mapa;
Organizar[][] celulasOrganizar;
int numLinhas;
int numColunas;

float tamanhoCelula;
float origemX;
float origemY;

//String nomeArquivo = "mapa_hospital_professor.txt";
String[] nomesArquivos;
int arquivoAtual = 0;
String mensagemErro = "";

color corChao;
color corParede;
color corGerador;
color corRemovedor;
color corTotem;
color corAssento;
color corEnfermeiro;
color corMedico;
color corGrade;
PImagem imagem1;
PImagem imagem2;
PImagem imagem3;
PImagem imagem4;
PImagem imagem5;
PImagem imagem6;
PImagem imagem7;
PImagem imagem8;
PImagem imagem9;
PImagem imagem10;
PImagem imagem11;
PImagem imagem12;
PImagem imagem13;
PImagem imagem14;

int estados=0;

void settings() {
  size(LARGURA_JANELA, ALTURA_JANELA);
}

void setup() {
  surface.setTitle("Visualizador de mapa hospitalar");

  imagem1 = loadImage("paciente sem identificação.png");
  imagem2 = loadImage("paciente sem risco.png");
imagem3 = loadImage("paciente com risco.png");
imagem4 = loadImage("paciente alto risco.png");
imagem5 = loadImage("paciente sem risco pref.png");
imagem6 = loadImage("paciente com risco pref.png");
imagem7 = loadImage("paciente alto risco pref.png");
imagem8 = loadImage("medico.png");
imagem9 = loadImage("enfermeira.png");
imagem10 = loadImage("gerador e removedor.png");
imagem11 = loadImage("tela d senhas.png");
imagem12 = loadImage("parede.png");
imagem13 = loadImage("chao.png");
imagem14 = loadImage("assento.png");

  corChao       = color(239, 229, 194); // bege
  corParede     = color(205, 164, 112); // marrom claro
  corGerador    = color(20, 155, 45);   // verde
  corRemovedor  = color(225, 45, 55);   // vermelho
  corTotem      = color(50, 90, 225);   // azul
  corAssento    = color(115, 62, 31);   // marrom escuro
  corEnfermeiro = color(35);            // preto
  corMedico     = color(250, 205, 20);  // amarelo
  corGrade      = color(175, 151, 112);
  
  nomesArquivos = encontrarArquivos();

  if (nomesArquivos.length == 0) {
  mensagemErro = "Nenhum arquivo .txt encontrado.";
  }else {
    mensagemErro = "Nenhum arquivo .txt encontrado.";
  }
  //carregarMapa(nomeArquivo);
}

void draw() {
  maquinaEstados();
}

void carregarMapa(String arquivo) {
  mensagemErro = "";

  String[] linhas = loadStrings(arquivo);

  if (linhas == null || linhas.length == 0) {
    mensagemErro = "Não foi possível abrir o arquivo: " + arquivo;
    return;
  }

  String[] dimensoes = splitTokens(trim(linhas[0]));

  if (dimensoes.length != 2) {
    mensagemErro = "A primeira linha deve conter dois inteiros: n m.";
    return;
  }

  try {
    numLinhas = Integer.parseInt(dimensoes[0]);
    numColunas = Integer.parseInt(dimensoes[1]);
  }
  catch (Exception e) {
    mensagemErro = "As dimensões do mapa devem ser números inteiros.";
    return;
  }

  if (numLinhas <= 0 || numColunas <= 0) {
    mensagemErro = "As dimensões do mapa devem ser positivas.";
    return;
  }

  if (linhas.length != numLinhas + 1) {
    mensagemErro =
      "Quantidade de linhas inválida. Esperado: " +
      numLinhas + ". Encontrado: " + (linhas.length - 1) + ".";
    return;
  }

  mapa = new char[numLinhas][numColunas];
  celulasOrganizar = new Organizar[numLinhas][numColunas];


  int geradores = 0;
  int removedores = 0;

  for (int i = 0; i < numLinhas; i++) {
    String linha = linhas[i + 1];

    if (linha.length() != numColunas) {
      mensagemErro =
        "A linha " + (i + 2) + " deveria possuir " +
        numColunas + " caracteres, mas possui " + linha.length() + ".";
      return;
    }
stroke(corGrade);
  strokeWeight(1);

  

    for (int j = 0; j < numColunas; j++) {
      char tipo = linha.charAt(j);
      
      definidorCelulas(tipo,i,j);

      if (!tipoValido(tipo)) {
        mensagemErro =
          "Caractere inválido '" + tipo + "' na linha " +
          (i + 2) + ", coluna " + (j + 1) + ".";
        return;
      }
for (int i = 0; i < numLinhas; i++) {
    for (int j = 0; j < numColunas; j++) {
      char tipo1 = mapa[i][j];

      float x = origemX + j * tamanhoCelula;
      float y = origemY + i * tamanhoCelula;

      fill(corDaCelula(tipo));
      rect(x, y, tamanhoCelula, tamanhoCelula);

      // DESENHA A IMAGEM DA CÉLULA
      desenharImagem(tipo, x, y);
 }
  }

      mapa[i][j] = tipo;

      if (tipo == 'G') geradores++;
      if (tipo == 'R') removedores++;
    }
  }

  if (geradores != 1) {
    mensagemErro =
      "O mapa deve possuir exatamente um gerador (G). Encontrados: " +
      geradores + ".";
    return;
  }

  if (removedores != 1) {
    mensagemErro =
      "O mapa deve possuir exatamente um removedor (R). Encontrados: " +
      removedores + ".";
    return;
  }

  calcularGeometria();
}

boolean tipoValido(char tipo) {
  return tipo == 'G' ||
         tipo == 'R' ||
         tipo == 'T' ||
         tipo == 'A' ||
         tipo == 'E' ||
         tipo == 'M' ||
         tipo == '#' ||
         tipo == '.';
}

void calcularGeometria() {
  float larguraDisponivel =
    width - 2 * MARGEM - LARGURA_LEGENDA;

  float alturaDisponivel =
    height - ALTURA_CABECALHO - 2 * MARGEM;

  tamanhoCelula = min(
    larguraDisponivel / numColunas,
    alturaDisponivel / numLinhas
  );

  origemX = MARGEM;
  origemY =
    ALTURA_CABECALHO +
    (alturaDisponivel - numLinhas * tamanhoCelula) / 2.0;
}

void desenharMapa() {
  stroke(corGrade);
  strokeWeight(1);

  for (int i = 0; i < numLinhas; i++) {
    for (int j = 0; j < numColunas; j++) {
      char tipo = mapa[i][j];

      float x = origemX + j * tamanhoCelula;
      float y = origemY + i * tamanhoCelula;

      fill(corDaCelula(tipo));
      rect(x, y, tamanhoCelula, tamanhoCelula);

      if (tipo != '.' && tipo != '#') {
        desenharSimbolo(tipo, x, y);
      }
    }
  }

  noFill();
  stroke(90);
  strokeWeight(2);
  rect(
    origemX,
    origemY,
    numColunas * tamanhoCelula,
    numLinhas * tamanhoCelula
  );
}

color corDaCelula(char tipo) {
  switch (tipo) {
  case '#':
    return corParede;
  case 'G':
    return corGerador;
  case 'R':
    return corRemovedor;
  case 'T':
    return corTotem;
  case 'A':
    return corAssento;
  case 'E':
    return corEnfermeiro;
  case 'M':
    return corMedico;
  default:
    return corChao;
  }
}

void desenharSimbolo(char tipo, float x, float y) {
  float tamanhoFonte = constrain(tamanhoCelula * 0.48, 9, 22);

  textAlign(CENTER, CENTER);
  textSize(tamanhoFonte);

  if (tipo == 'M') {
    fill(35);
  } else {
    fill(255);
  }

  text(
    str(tipo),
    x + tamanhoCelula / 2.0,
    y + tamanhoCelula / 2.0 - 1
  );

}

void desenharCabecalho() {
  fill(35);
  textAlign(LEFT, TOP);
  textSize(26);
  text("Mapa do Hospital", MARGEM, 16);

  textSize(14);
  fill(90);
  text(
    //"Arquivo: " + nomeArquivo +
    "   |   Pressione R para recarregar",
    MARGEM,
    51
  );
}

void desenharLegenda() {
  float x = width - LARGURA_LEGENDA + 26;
  float y = ALTURA_CABECALHO + 20;

  fill(40);
  textAlign(LEFT, TOP);
  textSize(20);
  text("Legenda", x, y);
  textSize(14);

  y += 42;
  itemLegenda(x, y, '.', "Chão", corChao);
  y += 38;
  itemLegenda(x, y, '#', "Parede", corParede);
  y += 38;
  itemLegenda(x, y, 'G', "Gerador", corGerador);
  y += 38;
  itemLegenda(x, y, 'R', "Removedor", corRemovedor);
  y += 38;
  itemLegenda(x, y, 'T', "Totem", corTotem);
  y += 38;
  itemLegenda(x, y, 'A', "Assento", corAssento);
  y += 38;
  itemLegenda(x, y, 'E', "Enfermeiro", corEnfermeiro);
  y += 38;
  itemLegenda(x, y, 'M', "Médico", corMedico);

  y += 62;
  fill(60);
  textSize(13);
  text(
    "Dimensões: " + numLinhas +
    " × " + numColunas,
    x,
    y
  );
}

void itemLegenda(
  float x,
  float y,
  char simbolo,
  String descricao,
  color cor
) {
  stroke(80);
  strokeWeight(1);
  fill(cor);
  rect(x, y, 25, 25);

  fill(simbolo == 'M' ? 35 : 255);
  textAlign(CENTER, CENTER);
  textSize(13);
  text(str(simbolo), x + 12.5, y + 12);

  fill(45);
  textAlign(LEFT, CENTER);
  textSize(14);
  text(descricao, x + 38, y + 12);
}

void desenharInformacaoCelula() {
  int coluna = floor((mouseX - origemX) / tamanhoCelula);
  int linha = floor((mouseY - origemY) / tamanhoCelula);

  if (
    linha < 0 || linha >= numLinhas ||
    coluna < 0 || coluna >= numColunas
  ) {
    return;
  }

  char tipo = mapa[linha][coluna];

  float painelX = width - LARGURA_LEGENDA + 26;
  float painelY = height - 125;

  fill(235);
  stroke(170);
  rect(painelX, painelY, LARGURA_LEGENDA - 52, 78, 6);

  fill(40);
  textAlign(LEFT, TOP);
  textSize(14);
  text("Célula sob o mouse", painelX + 12, painelY + 10);

  text(
    "Linha: " + linha +
    "\nColuna: " + coluna +
    "\nTipo: " + tipo + " — " + nomeDoTipo(tipo),
    painelX + 12,
    painelY + 31
  );
}

String nomeDoTipo(char tipo) {
  switch (tipo) {
  case '#':
    return "parede";
  case 'G':
    return "gerador";
  case 'R':
    return "removedor";
  case 'T':
    return "totem";
  case 'A':
    return "assento";
  case 'E':
    return "enfermeiro";
  case 'M':
    return "médico";
  default:
    return "chão";
  }
}

void desenharErro() {
  fill(255, 235, 235);
  stroke(190, 40, 40);
  strokeWeight(2);
  rect(MARGEM, ALTURA_CABECALHO, width - 2 * MARGEM, 130, 8);

  fill(150, 25, 25);
  textAlign(LEFT, TOP);
  textSize(20);
  text("Erro ao carregar o mapa", MARGEM + 18, ALTURA_CABECALHO + 18);

  textSize(15);
  text(
    mensagemErro,
    MARGEM + 18,
    ALTURA_CABECALHO + 55,
    width - 2 * MARGEM - 36,
    65
  );
}

void keyPressed() {
  if(estados==1){
  if (key == 'r' || key == 'R') {
    //carregarMapa(nomeArquivo);
  } else if (key =='p'||key == 'P') {
    estados=2;
  }
  } 
}

  int linhazinha=90;
  int coluninha=90;
void desenharmenu(){
  linhazinha=90;
  coluninha=90;
  background(239, 229, 194);
  noStroke();
  fill(200, 230, 180);
  rect(70,70,width/1,height/1);
  fill(1);
  for(int x=0;x<nomesArquivos.length;x++){
    rect(coluninha, linhazinha,150,150);
    coluninha=coluninha+160;
    if(coluninha+150>width){
      coluninha=90;
      linhazinha=linhazinha+160;
    }
  }
}

void maquinaEstados() {
  if(estados==0){
    menuINICIO();
  } else if (estados==1){
    jogo();
  } else if (estados==2){
    menuMEIO();
  } else {
    textAlign(LEFT, TOP);
    textSize(20);
    text("estados não definididos (otaro)", MARGEM + 18, ALTURA_CABECALHO + 18);
  }
}

void menuINICIO(){
  desenharmenu();
}

void jogo(){
  background(245);

  desenharCabecalho();

  if (!mensagemErro.equals("")) {
    desenharErro();
    return;
  }

  desenharMapa();
  desenharLegenda();
  desenharInformacaoCelula();
}

void menuMEIO(){
  background(255);
  for(int i=1;i<4;i++){
    fill(0,25*i,50*i);
  rect(100,150*i,700,100);
  }
}

String[] encontrarArquivos() {
  File pasta = new File(sketchPath("data"));
  File[] arquivos = pasta.listFiles();

  ArrayList<String> nomes = new ArrayList<String>();

  if (arquivos != null) {
    for (File arquivo : arquivos) {
      if (arquivo.isFile() && arquivo.getName().endsWith(".txt")) {
        nomes.add(arquivo.getName());
      }
    }
  }

  return nomes.toArray(new String[0]);
}

void mousePressed(){
  if(estados==0){
    int y=90;
    int x=90;
    
    for (int i = 0; i < nomesArquivos.length; i++) {

      // Verifica se clicou neste quadrado
      if (mouseX >= x && mouseX <= x + 150 &&
          mouseY >= y && mouseY <= y + 150) {

        arquivoAtual = i;

        carregarMapa(nomesArquivos[arquivoAtual]);

        estados = 1;

        return;
      }

      // Vai para o próximo quadrado
      x = x + 160;

      // Se passou da largura, pula para a próxima linha
      if (x + 150 > width) {
        x = 90;
        y = y + 160;
      }
    }
  } else if (estados==2){
    if(mouseX >= 100 && mouseX <= 800 &&
          mouseY >= 150 && mouseY <= 250) {
            estados=1;
      
    }
    else if(mouseX >= 100 && mouseX <= 800 &&
          mouseY >= 300 && mouseY <= 400) {
            estados=1;
            //adicionar alguma coisa com o codigo completo
  } else if (mouseX >= 100 && mouseX <= 800 &&
          mouseY >= 450 && mouseY <= 550) {
            estados=0;
  }
}
}

void definidorCelulas(char tipo,int linha, int coluna){
   celulasOrganizar[linha][coluna] = new Organizar(linha, coluna);
   celulasOrganizar[linha][coluna].definircelula(tipo);
  if(tipo=='.'){
    celulasOrganizar[linha][coluna] = new Chao(linha, coluna);
    celulasOrganizar[linha][coluna].imprimirChao();
  } else if(tipo=='#'){
    celulasOrganizar[linha][coluna] = new parede(linha, coluna);
  } else if (tipo=='G'){
    celulasOrganizar[linha][coluna] = new gerador(linha, coluna);
  } else if (tipo=='R'){
    celulasOrganizar[linha][coluna] = new removedor(linha, coluna);
  } else if (tipo=='T'){
    celulasOrganizar[linha][coluna] = new totem(linha, coluna);
  } else if (tipo=='A'){
    celulasOrganizar[linha][coluna] = new assento(linha, coluna);
  } else if (tipo=='E'){
    celulasOrganizar[linha][coluna] = new enfermeira(linha, coluna);
  } else if (tipo=='M'){
    celulasOrganizar[linha][coluna] = new medico(linha, coluna);
  }
}


void desenharImagem(char tipo, float x, float y) {

  PImage imagem = null;

  if (tipo == 'G') {
    imagem = imagem10;
  } else if (tipo == 'R') {
    imagem = imagem10;
  } else if (tipo == 'A') {
    imagem = imagem14;
  } else if (tipo == 'E') {
    imagem = imagem9;
  } else if (tipo == 'M') {
    imagem = imagem8;
  } else if (tipo == '#') {
    imagem = imagem12;
  } else if (tipo == '.') {
    imagem = imagem13;
  }

  if (imagem != null) {
    image(imagem, x, y, tamanhoCelula, tamanhoCelula);
  }
}
