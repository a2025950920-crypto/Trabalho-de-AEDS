class CalculadorTempos {

  // exponencial, media 5.0s
  static float calcularProximoSpawn() {
    float mediaSpawn = 5.0f;
    float u = random(0.0001f, 0.9999f);
    return -mediaSpawn * log(1.0f - u);
  }

  // normal, media 6.0s, desvio 2.0s, minimo 2.0s
  static float calcularTempoTriagem() {
    float tempo = 6.0f + (2.0f * (float) randomGaussian());
    return max(tempo, 2.0f);
  }

  // normal, media 12.0s, desvio 4.0s, minimo 4.0s
  static float calcularTempoConsulta() {
    float tempo = 12.0f + (4.0f * (float) randomGaussian());
    return max(tempo, 4.0f);
  }
}
