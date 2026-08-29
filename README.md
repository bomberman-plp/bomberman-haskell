# 💣 Bomberman em Prolog

> Implementação do jogo clássico **Bomberman** via terminal utilizando o paradigma de programação lógica.
> Desenvolvido para a disciplina de **Paradigmas de Linguagem de Programação (PLP)** na **UFCG**.

---

## 🎮 O Projeto

O projeto consiste em recriar a mecânica fundamental do Bomberman rodando direto no terminal CLI. O sistema gerencia o mapa através de matrizes lógicas, manipula estados em memória e realiza renderizações dinâmicas a cada ação do jogador.

### 🌟 Funcionalidades
* **Renderização no Terminal:** Interface baseada em texto com sequências de escape ANSI.
* **Leitura Dinâmica de Mapas:** Carregamento de arquivos `.txt` convertidos em estruturas de dados lógicas.
* **Física e Colisão:** Validação de células de chão (`.`), blocos de madeira destruíveis (`x`) e paredes inquebráveis (`#`).
* **Arquitetura Modular:** Código 100% separado em responsabilidades (desenho, movimentação, loop e lógica).

---

## 🧠 Por que Prolog? (Paradigma Lógico)

Diferente de linguagens imperativas como Python ou C, o Prolog opera no **Paradigma Lógico** 
fundamentado na Lógica de Predicados de Primeira Ordem. Em vez de instruir *como* a máquina deve 
executar passo a passo, declaramos **fatos** e **regras**.

### Conceitos aplicados no projeto:
* **Fatos e Regras:** Representação do mapa como coleções de termos `((X, Y), Tile)` e regras de colisão (`is_empty/2`).
* **Unificação e Pattern Matching:** Tradução automática de caracteres em entidades do jogo (`asset_to_tile/2`).
* **Recursão Direta:** Controle do **Game Loop** sem depender de laços clássicos (`while`/`for`).
* **Imutabilidade:** Atualizações de estado geram novas instâncias da matriz usando o mecanismo de *head/tail* e *backtracking*.

---

# Como executar

`runhaskell -isrc Main.hs`
