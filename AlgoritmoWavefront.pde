class AlgoritmoWavefront {
  int[][] calcularWavefront(int destinoL, int destinoC, char[][] mapa) {
    int numLinhas = mapa.length;
    int numColunas = mapa[0].length;
    int[][] distancias = new int[numLinhas][numColunas];

    for (int i = 0; i < numLinhas; i++) {
      for (int j = 0; j < numColunas; j++) {
        distancias[i][j] = -1;
      }
    }

    FilaCoordenadas fila = new FilaCoordenadas();

    distancias[destinoL][destinoC] = 0;
    fila.enfileirar(new Coordenada(destinoL, destinoC));

    int[] dLinha = {-1, 1, 0, 0};
    int[] dColuna = {0, 0, -1, 1};

    while (!fila.vazia()) {
      Coordenada atual = fila.desenfileirar();

      for (int i = 0; i < 4; i++) {
        int novoL = atual.linha + dLinha[i];
        int novoC = atual.coluna + dColuna[i];

        if (novoL >= 0 && novoL < numLinhas && novoC >= 0 && novoC < numColunas) {
          
          if (mapa[novoL][novoC] != '#' && distancias[novoL][novoC] == -1) {
            distancias[novoL][novoC] = distancias[atual.linha][atual.coluna] + 1;
            fila.enfileirar(new Coordenada(novoL, novoC));
          }
        }
      }
    }

    return distancias;
  }
}
