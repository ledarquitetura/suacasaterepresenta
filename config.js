/* =====================================================================
   CONFIGURAÇÃO PÚBLICA — "Sua Casa te Representa?"
   ---------------------------------------------------------------------
   Este arquivo é lido pelo site (index.html) e pelo Painel de Insights
   (insights.html). Ele NÃO deve conter segredos.

   - aiEndpoint: URL do backend que conversa com a IA (ex.: a função
     /api/analyze deste projeto publicada na Vercel). A chave da API de IA
     fica SOMENTE no servidor, como variável de ambiente.
     O site testa o endpoint ao abrir: se a IA não responder (arquivo aberto
     no computador, hospedagem sem backend ou chave ausente), entra no
     MODO DEMONSTRAÇÃO (leitura local, sem IA, claramente sinalizada).

   - supabaseUrl / supabaseAnonKey: projeto Supabase para métricas.
     A "anon key" é pública por definição; a segurança vem das políticas
     RLS do arquivo supabase/schema.sql (anônimo só pode INSERIR eventos;
     somente administradores autenticados podem LER).
     Vazio = métricas ficam apenas neste navegador (modo de teste local).
   ===================================================================== */
window.APP_CONFIG = {
  aiEndpoint: "/api/analyze", // na Vercel funciona sozinho; aberto no computador, vira demonstração
  supabaseUrl: "",         // ex.: "https://abcdefgh.supabase.co"
  supabaseAnonKey: "",     // chave "anon public" do Supabase
  instagramUrl: "https://www.instagram.com/led_arquitetura?rpxt=NzNzMTl1c3NuaGw5",

  /* Fotografias opcionais. Se preenchidas, substituem as ilustrações
     geradas pelo site (use imagens próprias ou licenciadas). */
  images: {
    hero: "",
    sala: "",
    quarto: "",
    cozinha: ""
  }
};
