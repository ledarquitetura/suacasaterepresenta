# Sua casa te representa?

Experiência digital gamificada: a pessoa envia uma foto de um ambiente da própria casa, recebe uma leitura visual, diz se essa leitura a representa, responde a um questionário adaptativo e, no fim, recebe um termômetro de conexão, um book de sugestões em três níveis e um relatório para imprimir ou salvar em PDF. Depois vêm a avaliação por estrelas e a chamada para o Instagram do LED Arquitetura.

## Arquivos

| Arquivo | Para que serve |
|---|---|
| `index.html` | A experiência completa, em um único arquivo (HTML, CSS e JavaScript puro). |
| `config.js` | Configuração pública: endpoint da IA, Supabase, link do Instagram e fotos opcionais. **Não guarda segredos.** |
| `insights.html` | Painel de Insights, a área administrativa. Não tem link no site público. |
| `api/analyze.js` | Backend serverless que conversa com a IA. A chave fica só no servidor. |
| `vercel.json`, `package.json` | Configuração da publicação na Vercel. |
| `supabase/schema.sql` | Tabelas e políticas de segurança (RLS) das métricas. |

## Publicar o site com a IA funcionando (passo a passo)

Abrir o `index.html` pelo WhatsApp ou direto do celular não funciona: o app não executa o site e o arquivo fica sem o `config.js` e sem a IA. O site precisa estar publicado em um endereço (link). O caminho recomendado é a **Vercel**, que é gratuita para começar e roda o site e a IA juntos.

**1. Crie a chave da IA**
- Acesse **console.anthropic.com**, crie a conta e adicione créditos em *Billing*.
- Em *API Keys*, crie uma chave e copie (começa com `sk-ant-`).
- Guarde a chave só para o passo 3. Não coloque no código e não envie por WhatsApp.

**2. Suba os arquivos no GitHub**
- Crie uma conta em **github.com** e um repositório novo (pode ser privado).
- Clique em *Add file → Upload files* e arraste **todo o conteúdo** desta pasta. As pastas `api` e `supabase` precisam ir junto.

**3. Publique na Vercel**
- Em **vercel.com**, entre com a conta do GitHub e clique em *Add New → Project*.
- Escolha o repositório. Não é preciso mudar nenhuma configuração.
- Antes de clicar em *Deploy*, abra *Environment Variables* e crie:
  - `ANTHROPIC_API_KEY` = a chave do passo 1.
  - `ALLOWED_ORIGIN` = o endereço final do site (opcional; pode adicionar depois).
- Clique em **Deploy**. Em cerca de 1 minuto você recebe um link como `https://sua-casa.vercel.app`.

**4. Confira**
- Abra `https://SEU-LINK/api/analyze`. Deve aparecer `{"ok":true,"ai":true}`.
  - Se aparecer `"ai":false`, a chave não foi salva. Corrija em *Settings → Environment Variables* e faça *Redeploy*.
- Abra o site no celular. O selo "Modo demonstração" some e, ao enviar a foto, aparece a caixa de autorização do envio para a IA.
- A partir daí, a leitura da foto e o book de sugestões passam a ser escritos pela IA.

**5. Domínio próprio (opcional)**
- Em *Settings → Domains*, conecte um endereço como `suacasa.com.br`.
- Depois atualize `ALLOWED_ORIGIN` para esse endereço.

O site detecta a IA sozinho. Se ela não responder (arquivo aberto no computador, hospedagem sem a função ou chave ausente), ele entra em **modo demonstração**, sinalizado na tela.

**Custo:** cada jornada faz 2 chamadas à IA (leitura da foto e diagnóstico). Acompanhe o gasto em console.anthropic.com e defina um limite mensal em *Limits*.

## Testar no computador (modo demonstração)

Dê dois cliques em `index.html`. Nesse modo:
- A leitura da foto mede luz, cor, densidade visual e paleta no próprio navegador. Os textos seguem regras pré-definidas, e a tela avisa que nenhuma IA foi usada.
- A foto não sai do aparelho.
- Sem Supabase, as métricas ficam neste navegador e aparecem no painel como "eventos deste navegador".

O painel está em `insights.html`. Sem Supabase, ele mostra dados fictícios ou os eventos deste navegador, sempre identificados.

## Como a IA funciona no site

- A chave fica só na Vercel (`ANTHROPIC_API_KEY`), nunca no navegador.
- A pessoa precisa **autorizar o envio da foto**. A foto vai redimensionada e não é armazenada.
- A IA devolve dados estruturados, que o site valida antes de exibir.
- Se a IA falhar, a pessoa pode tentar de novo, trocar a foto ou seguir com uma leitura de demonstração identificada.
- **A pontuação nunca é escolhida pela IA.** Ela é calculada pelos critérios abaixo. A IA personaliza os textos da leitura, dos pontos fortes, dos desalinhamentos e das sugestões.

## Ativar as métricas reais (Supabase)

1. Crie um projeto no Supabase e rode `supabase/schema.sql` no SQL Editor.
2. Em **Authentication → Users**, crie o usuário administrador. Depois rode:
   `insert into public.admins (user_id) values ('<UUID-do-usuario>');`
3. Em `config.js`, preencha `supabaseUrl` e `supabaseAnonKey`. A chave "anon public" é pública por definição. Faça o upload do `config.js` atualizado no GitHub; a Vercel publica sozinha.

Como a segurança funciona:
- Visitantes só podem **inserir** eventos.
- Só administradores autenticados podem **ler**.
- Ninguém consegue editar ou apagar pela API.
- Nenhuma senha fica no código; o login do painel usa o Supabase Auth.

**O que é registrado.** Os eventos são `page_view`, `journey_started`, `environment_selected`, `photo_uploaded`, `ai_analysis_completed`, `interpretation_reacted`, `questionnaire_completed`, `diagnosis_generated`, `report_viewed`, `experience_rated`, `instagram_clicked` e `journey_abandoned`. Cada um leva data e hora e um identificador de sessão anônimo.

**O que nunca é registrado.** Fotos, nome, e-mail, telefone e o texto livre do questionário. O comentário da avaliação é opcional e anônimo.

**LGPD.** Na primeira visita aparece um aviso de consentimento. Se a pessoa recusar, nada é enviado. Ela pode mudar a escolha a qualquer momento pelo rodapé ("Preferências de métricas").

## Como a pontuação é calculada

Índice = **35%** Funcionalidade e rotina + **30%** Identidade estética + **20%** Conforto e atmosfera + **15%** Atendimento às prioridades.

- **Base.** Cada dimensão começa de um valor definido pela reação à leitura:
  - "Sim, me representa": 74 / 84 / 76 / 72
  - "Em partes": 60 / 60 / 60 / 56
  - "Não me representa": 46 / 36 / 46 / 42
- **Ajustes explícitos das respostas.** Exemplos: "o quarto não proporciona descanso" tira 16 pontos de Conforto; "falta muito espaço para guardar" tira 12 de Funcionalidade.
- **Comparação entre a foto e as preferências.** As referências visuais escolhidas são comparadas com as medidas da foto (luz, cor, densidade e materiais naturais). A sensação desejada é comparada com a atmosfera medida.
- **Limites.** Cada dimensão fica entre 8% e 97%.
- **Faixas.**
  - 0–39%: Baixa conexão
  - 40–59%: Em desenvolvimento
  - 60–79%: Boa conexão
  - 80–100%: Alta conexão

Na tela do termômetro, o botão **"Como esse número foi calculado?"** mostra cada contribuição. É útil para apresentar aos sócios.

## Questionário adaptativo

São de 8 a 10 perguntas, uma por vez, organizadas em cinco blocos:
- **A. Personalidade.**
- **B. Rotina.** As perguntas mudam conforme o ambiente (sala, quarto ou cozinha).
- **C. Preferências estéticas**, com escolhas visuais.
- **D. Prioridades**, até 3.
- **E. Principal incômodo**, com campo livre.

Até duas perguntas de aprofundamento entram conforme as respostas. Por exemplo:
- quem gosta de receber pessoas → pergunta sobre acomodação;
- quem diz que o descanso está comprometido → perguntas sobre silêncio e luz à noite;
- quem diz que a estética não o representa → pergunta sobre linguagens visuais.

## Imagens

As imagens do site são ilustrações em SVG geradas no próprio código, com a paleta e os arcos inspirados no Branding Book. São leves, não dependem de internet e não têm problema de direitos.

Para usar fotografias próprias ou licenciadas, preencha `images.hero`, `images.sala`, `images.quarto` e `images.cozinha` em `config.js`.

## Identidade visual

Tudo foi derivado do Branding Book e usado apenas como referência estética:
- **Paleta.** Viva `#9CAA39`, Argamassa `#E3D9AC`, Urbano `#3E162F`, Aço `#283145`, Tijolo `#E9B349` e Solo `#9D491F`.
- **Formas.** Painéis com cantos generosos, molduras em arco, arcos concêntricos e um padrão próprio de "arco + barra" inspirado nos cobogós.
- **Tipografia.** *Outfit* substitui a Pogonia, que não está disponível na web; *DM Mono* entra nos rótulos.

O nome LED Arquitetura aparece apenas no crédito "Desenvolvido pelo LED Arquitetura" (rodapé e relatório) e na seção final com o link para o Instagram. Não há logo.
