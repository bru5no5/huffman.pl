%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%                              %%%%%%%%%%
%%%%%     Bruno Gustavo Rocha - 10400926     %%%%%
%%%%%%%%%%                              %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Para executar o algoritmo, escreva e execute a seguinte lista de comandos no Terminal:
% swipl
% consult("huffman.pl").
% main().

% Esse código criará os arquivos "arvore.txt", "freq.txt", "out.txt" e "tabela_codigo.txt" no mesmo diretório.

% Predicado principal para contar a frequência de caracteres em uma string.
contaCaracteres(String, Frequencia) :-
    string_chars(String, ListaCaracteres),
    contaCaracteres(ListaCaracteres, [], Frequencia).

% Predicados auxiliares
contaCaracteres([], Freq, Freq).
contaCaracteres([C|Cs], Acc, Freq) :-
    insereAtualiza(C, Acc, NovoAcc),
    contaCaracteres(Cs, NovoAcc, Freq).

insereAtualiza(C, [], [(C, 1)]).
insereAtualiza(C, [(X, N)|Xs], [(X, N1)|Xs]) :- C = X, N1 is N + 1.
insereAtualiza(C, [(X, N)|Xs], [(X, N)|R]) :- insereAtualiza(C, Xs, R).

% Predicado para calcular a frequência de uma árvore
frequencia(f(_, F), F). % Folha: retorna a frequência
frequencia(no(F, _, _), F). % Nó: retorna a soma das frequências das subárvores

% Predicado para combinar duas árvores de menor frequência em uma nova árvore
combinaArvores([A1, A2 | Resto], [no(F, A1, A2) | Resto]) :-
    frequencia(A1, F1),
    frequencia(A2, F2),
    F is F1 + F2.
combinaArvores(Arvores, Arvores) :- length(Arvores, 1). % Caso base: lista com uma única árvore

% Ordenação da lista de frequências
quicksort([], []).
quicksort([X|Xs], Ordenada) :-
    partit(X, Xs, Menores, Maiores),
    quicksort(Menores, OrdenadaMenores),
    quicksort(Maiores, OrdenadaMaiores),
    append(OrdenadaMenores, [X|OrdenadaMaiores], Ordenada).

partit(_, [], [], []).
partit(X, [Y|Ys], [Y|Menores], Maiores) :-
    frequencia(Y, FY),
    frequencia(X, FX),
    FY =< FX,
    partit(X, Ys, Menores, Maiores).
partit(X, [Y|Ys], Menores, [Y|Maiores]) :-
    frequencia(Y, FY),
    frequencia(X, FX),
    FY > FX,
    partit(X, Ys, Menores, Maiores).

% Cria a árvore de Huffman a partir de uma lista de tuplas (caractere, frequência)
criaArvore(ListaFreq, Arvore) :-
    maplist(tupla_para_folha, ListaFreq, ListaFolhas),
    quicksort(ListaFolhas, ListaOrdenada),
    criaArvoreRec(ListaOrdenada, Arvore).

tupla_para_folha((C, F), f(C, F)). % Converte (caractere, frequência) em folha

% Função recursiva para combinar as árvores e formar a árvore de Huffman final
criaArvoreRec([Arvore], Arvore). % Caso base: uma única árvore
criaArvoreRec(Arvores, ArvoreFinal) :-
    combinaArvores(Arvores, Combinada),
    quicksort(Combinada, Ordenada),
    criaArvoreRec(Ordenada, ArvoreFinal).

% Predicado para criar a tabela de códigos de Huffman a partir de uma árvore de Huffman
criaTabela(f(C, _), [(C, "")]). % Caso base: folha, retorna o caractere com código vazio
criaTabela(no(_, Esq, Dir), Tabela) :-
    criaTabela(Esq, TabelaEsq),
    criaTabela(Dir, TabelaDir),
    adicionaPrefixo('0', TabelaEsq, TabelaEsqPrefixo),
    adicionaPrefixo('1', TabelaDir, TabelaDirPrefixo),
    append(TabelaEsqPrefixo, TabelaDirPrefixo, Tabela).

% Predicado auxiliar para adicionar um prefixo ('0' ou '1') ao código de cada caractere em uma subárvore
adicionaPrefixo(_, [], []).
adicionaPrefixo(Prefixo, [(C, Codigo)|Resto], [(C, NovoCodigo)|RestoComPrefixo]) :-
    atom_concat(Prefixo, Codigo, NovoCodigo),
    adicionaPrefixo(Prefixo, Resto, RestoComPrefixo).

% Predicado para codificar um caractere usando a tabela de códigos
codificaCaractere(C, [(C, Codigo)|_], Codigo) :- !. % Caso encontrado: retorna o código correspondente
codificaCaractere(C, [_|Resto], Codigo) :- codificaCaractere(C, Resto, Codigo). % Recursão para buscar o código

% Predicado para codificar uma lista de caracteres usando a tabela de códigos
codificaLista([], _, ""). % Caso base: lista vazia resulta em código vazio
codificaLista([C|Cs], TabelaCodigo, CodigoFinal) :-
    codificaCaractere(C, TabelaCodigo, Codigo),       % Encontra o código para o caractere atual
    codificaLista(Cs, TabelaCodigo, CodigoResto),     % Codifica o restante da lista
    atom_concat(Codigo, CodigoResto, CodigoFinal).     % Concatena o código atual com o restante

% Predicado para codificar o conteúdo de um arquivo de texto usando a tabela de códigos de Huffman
codificaArquivo(TabelaCodigo, CodigoFinal) :-
    read_file_to_string('in.txt', Conteudo, []),       % Lê o conteúdo do arquivo 'in.txt'
    string_chars(Conteudo, ListaCaracteres),           % Converte o conteúdo em uma lista de caracteres
    codificaLista(ListaCaracteres, TabelaCodigo, CodigoFinal). % Codifica a lista de caracteres



% Predicado principal que lê um arquivo, codifica seu conteúdo e escreve o resultado em outro arquivo
main :-
    writeln("Creditos do algoritmo: Bruno Gustavo Rocha"),
    
    % Lê o conteúdo do arquivo 'in.txt' e conta a frequência dos caracteres
    read_file_to_string('in.txt', Conteudo, []),
    contaCaracteres(Conteudo, TabelaFrequencia),
    
    % Salva a tabela de frequência no arquivo 'freq.txt'
    open('freq.txt', write, FreqFile),
    write(FreqFile, TabelaFrequencia),
    close(FreqFile),
    
    % Cria a árvore de Huffman e salva no arquivo 'arvore.txt'
    criaArvore(TabelaFrequencia, ArvoreHuffman),
    open('arvore.txt', write, ArvoreFile),
    write(ArvoreFile, ArvoreHuffman),
    close(ArvoreFile),
    
    % Cria a tabela de códigos de Huffman e salva no arquivo 'tabela_codigo.txt'
    criaTabela(ArvoreHuffman, TabelaCodigo),
    open('tabela_codigo.txt', write, CodigoFile),
    write(CodigoFile, TabelaCodigo),
    close(CodigoFile),
    
    % Codifica o conteúdo de 'in.txt' usando a tabela de códigos de Huffman
    codificaArquivo(TabelaCodigo, CodigoFinal),
    
    % Salva o conteúdo codificado no arquivo 'out.txt'
    open('out.txt', write, OutFile),
    write(OutFile, CodigoFinal),
    close(OutFile),
    
    writeln("Processamento concluido com sucesso.").