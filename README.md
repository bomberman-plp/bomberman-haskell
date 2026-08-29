# 💣 Bomberman em Haskell

> Implementação do jogo clássico **Bomberman** via terminal utilizando o paradigma de programação funcional.
> Desenvolvido para a disciplina de **Paradigmas de Linguagem de Programação (PLP)** na **UFCG**.

---

## 🎮 O Projeto

O projeto consiste em recriar a mecânica fundamental do Bomberman rodando direto no terminal CLI. 
O sistema gerencia o mapa através de estruturas de dados puras, manipula estados imutáveis a cada 
passo e realiza renderizações dinâmicas a cada ação do jogador.

### 🌟 Funcionalidades
* **Renderização no Terminal:** Interface baseada em texto utilizando sequências de escape ANSI.
* **Leitura Dinâmica de Mapas:** Carregamento e parsing de arquivos `.txt` em matrizes funcionais.
* **Física e Colisão:** Validação de células de chão, blocos de madeira destruíveis e paredes inquebráveis.
* **Arquitetura Modular:** Separação estrita de responsabilidades entre funções puras (regras/lógica) e funções de I/O (renderização/loop).

---

## 🧠 Por que Haskell? (Paradigma Funcional)

Diferente de linguagens imperativas, o Haskell opera no **Paradigma Funcional Puro**, onde o código é construído 
através da composição de funções matemáticas sem efeitos colaterais.

### Conceitos aplicados no projeto:
* **Imutabilidade e Transparência Referencial:** O estado do jogo nunca é alterado "in-place".
 Cada movimento do jogador gera um novo mapa totalmente novo a partir da função atual.
* **Pattern Matching:** Mapeamento declarativo de teclas para direções e tradução de caracteres para os elementos do mapa.
* **Sistema de Tipos Forte e Algébrico:** Uso de `Data Types` customizados (como `Tile`, `Position`, `GameMap`) para garantir segurança em tempo de compilação.
* **Separação com Monada I/O:** Isolamento total entre as funções puras do jogo (física e movimentação) e a Monada `IO` responsável por ler o teclado e desenhar na tela.

---

# Como executar

`runhaskell -isrc Main.hs`
