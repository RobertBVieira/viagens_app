# Controle de Viagens — App Flutter

App para registrar viagens com fotos, custos e duração. Cada viagem aparece como
um **card com carrossel de fotos** na tela inicial; ao tocar, abre os detalhes.

## Tecnologias
- **Flutter (Dart)**
- **SQLite** (`sqflite`) — banco local
- `image_picker` — câmera e galeria
- `path_provider` — guardar as fotos no diretório do app
- `crypto` — hash SHA-256 das senhas
- `intl` — moeda (R$) e datas (pt-BR)

## Banco de dados (3 tabelas)
1. **usuarios** — `id, nome, email (único), senha (hash)`
2. **viagens** — `id, usuario_id (FK), destino, data_inicio, data_fim, custo, observacoes`
3. **fotos** — `id, viagem_id (FK), caminho` (1 viagem → N fotos)

> As fotos ficam em tabela separada para manter as responsabilidades limpas
> (uma viagem tem várias fotos).

## Funcionalidade aplicada ao tema (vale 6 pontos)
A tela inicial exibe um **painel de resumo** com:
- **Gasto total** — soma do custo de todas as viagens do usuário;
- **Dias viajados** — soma da duração de todas as viagens (calculada a partir
  das datas de início e fim de cada viagem).

Isso transforma os dados cadastrados em informação útil: o usuário vê de imediato
quanto já gastou e quantos dias passou viajando.

## Como os requisitos são atendidos
| Requisito | Onde |
|-----------|------|
| Login (usuário/senha) | `login_screen.dart` + `auth_service.dart` |
| Cadastro de usuário | `cadastro_screen.dart` |
| Listagem | `home_screen.dart` (cards) |
| Cadastrar registro | `viagem_form_screen.dart` |
| Editar registro | `viagem_form_screen.dart` (modo edição) |
| Excluir registro | `viagem_detalhe_screen.dart` |
| Navegação entre telas | Login → Cadastro / Login → Home → Detalhe → Form |
| Funcionalidade aplicada | painel "Gasto total + Dias viajados" |

## Organização do projeto (separação de responsabilidades)
```
lib/
├── main.dart                 # ponto de entrada
├── theme.dart                # identidade visual
├── models/                   # estруtura dos dados
│   ├── usuario.dart
│   └── viagem.dart
├── db/
│   └── database_helper.dart  # acesso ao SQLite (persistência)
├── services/                 # regras de negócio
│   ├── auth_service.dart     # login/cadastro/sessão
│   └── photo_service.dart    # câmera/galeria
├── widgets/                  # componentes reutilizáveis
│   ├── photo_carousel.dart   # carrossel de fotos
│   └── viagem_card.dart      # card da home
└── screens/                  # telas (UI)
    ├── login_screen.dart
    ├── cadastro_screen.dart
    ├── home_screen.dart
    ├── viagem_form_screen.dart
    └── viagem_detalhe_screen.dart
```

## Como rodar
```bash
flutter pub get
flutter run
```
> Veja `PERMISSOES.txt` para as chaves de câmera/galeria (iOS já precisa
> adicionar manualmente no Info.plist; Android já está pronto).

## Roteiro sugerido para o vídeo (5 pontos)
1. Abrir o app → tela de login.
2. Clicar em "Cadastre-se", criar um usuário e voltar.
3. Fazer login.
4. Mostrar a home vazia → "Nova viagem".
5. Preencher destino, datas, custo, observações e **adicionar fotos**
   (uma da câmera, outra da galeria). Salvar.
6. Cadastrar uma segunda viagem.
7. Mostrar os **cards com o carrossel** funcionando (deslizar as fotos).
8. Destacar o painel **Gasto total + Dias viajados** atualizando.
9. Abrir uma viagem → mostrar detalhes e carrossel grande.
10. **Editar** a viagem (mudar custo/foto) e mostrar o resumo mudando.
11. **Excluir** uma viagem.
12. Sair (logout).
```
