-- ============================================================
-- SCHEMA — Sistema Financeiro Dra Mariana Leite
-- Execute no SQL Editor do Supabase Dashboard
-- ============================================================

-- Remove tabelas antigas (se existirem)
DROP TABLE IF EXISTS registros CASCADE;
DROP TABLE IF EXISTS procedimentos CASCADE;
DROP TABLE IF EXISTS custos_fixos CASCADE;
DROP TABLE IF EXISTS insumos CASCADE;
DROP TABLE IF EXISTS config_clinica CASCADE;

-- INSUMOS
CREATE TABLE insumos (
  id TEXT PRIMARY KEY,
  user_id UUID REFERENCES auth.users NOT NULL,
  categoria TEXT,
  nome TEXT NOT NULL,
  unidade TEXT,
  custo DECIMAL(10,4) NOT NULL DEFAULT 0,
  estoque DECIMAL(10,2) DEFAULT 0,
  estoque_min DECIMAL(10,2) DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE insumos ENABLE ROW LEVEL SECURITY;
CREATE POLICY "owner_insumos" ON insumos FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- CUSTOS FIXOS
CREATE TABLE custos_fixos (
  id TEXT PRIMARY KEY,
  user_id UUID REFERENCES auth.users NOT NULL,
  descricao TEXT NOT NULL,
  valor DECIMAL(10,2) NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE custos_fixos ENABLE ROW LEVEL SECURITY;
CREATE POLICY "owner_fixos" ON custos_fixos FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- PROCEDIMENTOS
CREATE TABLE procedimentos (
  id TEXT PRIMARY KEY,
  user_id UUID REFERENCES auth.users NOT NULL,
  nome TEXT NOT NULL,
  tempo DECIMAL(6,1) NOT NULL DEFAULT 0,
  preco DECIMAL(10,2) DEFAULT 0,
  ficha JSONB DEFAULT '[]',
  created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE procedimentos ENABLE ROW LEVEL SECURITY;
CREATE POLICY "owner_procedimentos" ON procedimentos FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- REGISTROS
CREATE TABLE registros (
  id TEXT PRIMARY KEY,
  user_id UUID REFERENCES auth.users NOT NULL,
  data DATE NOT NULL,
  proc_id TEXT,
  proc_nome TEXT,
  preco DECIMAL(10,2) NOT NULL DEFAULT 0,
  pagamento TEXT,
  custo_insumos DECIMAL(10,4) DEFAULT 0,
  custo_tempo DECIMAL(10,4) DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE registros ENABLE ROW LEVEL SECURITY;
CREATE POLICY "owner_registros" ON registros FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- CONFIG (1 linha por usuário)
CREATE TABLE config_clinica (
  user_id UUID PRIMARY KEY REFERENCES auth.users NOT NULL,
  horas DECIMAL(6,2) DEFAULT 139.41,
  imposto DECIMAL(5,2) DEFAULT 6,
  cartao DECIMAL(5,2) DEFAULT 3.5,
  lucro DECIMAL(5,2) DEFAULT 30,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE config_clinica ENABLE ROW LEVEL SECURITY;
CREATE POLICY "owner_config" ON config_clinica FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
