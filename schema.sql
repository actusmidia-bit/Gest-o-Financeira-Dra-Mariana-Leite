-- ============================================================
-- SCHEMA v5 — Sistema Financeiro Dra Mariana Leite
-- Execute no SQL Editor do Supabase Dashboard
-- ============================================================

DROP TABLE IF EXISTS recebimentos CASCADE;
DROP TABLE IF EXISTS compras_estoque CASCADE;
DROP TABLE IF EXISTS despesas_variaveis CASCADE;
DROP TABLE IF EXISTS pacientes CASCADE;
DROP TABLE IF EXISTS metas_mensais CASCADE;
DROP TABLE IF EXISTS financiamentos CASCADE;
DROP TABLE IF EXISTS registros CASCADE;
DROP TABLE IF EXISTS procedimentos CASCADE;
DROP TABLE IF EXISTS custos_fixos CASCADE;
DROP TABLE IF EXISTS insumos CASCADE;
DROP TABLE IF EXISTS config_clinica CASCADE;

CREATE TABLE insumos (
  id TEXT PRIMARY KEY, user_id UUID REFERENCES auth.users NOT NULL,
  categoria TEXT, nome TEXT NOT NULL,
  unidade TEXT,
  qtd_por_embalagem DECIMAL(10,4) DEFAULT NULL,
  unidade_uso TEXT DEFAULT NULL,
  custo DECIMAL(10,4) DEFAULT 0, estoque DECIMAL(10,2) DEFAULT 0,
  estoque_min DECIMAL(10,2) DEFAULT 0, created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE insumos ENABLE ROW LEVEL SECURITY;
CREATE POLICY "p_insumos" ON insumos FOR ALL USING (auth.uid()=user_id) WITH CHECK (auth.uid()=user_id);

CREATE TABLE custos_fixos (
  id TEXT PRIMARY KEY, user_id UUID REFERENCES auth.users NOT NULL,
  descricao TEXT NOT NULL, valor DECIMAL(10,2) DEFAULT 0,
  vencimento_dia INT DEFAULT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE custos_fixos ENABLE ROW LEVEL SECURITY;
CREATE POLICY "p_fixos" ON custos_fixos FOR ALL USING (auth.uid()=user_id) WITH CHECK (auth.uid()=user_id);

CREATE TABLE procedimentos (
  id TEXT PRIMARY KEY, user_id UUID REFERENCES auth.users NOT NULL,
  nome TEXT NOT NULL, categoria TEXT DEFAULT 'Geral',
  tempo DECIMAL(6,1) DEFAULT 0, preco DECIMAL(10,2) DEFAULT 0,
  sessoes_pacote INT DEFAULT 0,
  ficha JSONB DEFAULT '[]', created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE procedimentos ENABLE ROW LEVEL SECURITY;
CREATE POLICY "p_procs" ON procedimentos FOR ALL USING (auth.uid()=user_id) WITH CHECK (auth.uid()=user_id);

CREATE TABLE pacientes (
  id TEXT PRIMARY KEY, user_id UUID REFERENCES auth.users NOT NULL,
  nome TEXT NOT NULL, telefone TEXT, nascimento DATE, observacoes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE pacientes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "p_pacientes" ON pacientes FOR ALL USING (auth.uid()=user_id) WITH CHECK (auth.uid()=user_id);

CREATE TABLE registros (
  id TEXT PRIMARY KEY, user_id UUID REFERENCES auth.users NOT NULL,
  data DATE NOT NULL, proc_id TEXT, proc_nome TEXT, paciente_id TEXT, paciente_nome TEXT,
  preco DECIMAL(10,2) DEFAULT 0, pagamento TEXT, pagamentos JSONB DEFAULT NULL,
  parcelas INT DEFAULT 1,
  custo_insumos DECIMAL(10,4) DEFAULT 0, custo_tempo DECIMAL(10,4) DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE registros ENABLE ROW LEVEL SECURITY;
CREATE POLICY "p_regs" ON registros FOR ALL USING (auth.uid()=user_id) WITH CHECK (auth.uid()=user_id);

CREATE TABLE recebimentos (
  id TEXT PRIMARY KEY, user_id UUID REFERENCES auth.users NOT NULL,
  reg_id TEXT, descricao TEXT, data_prevista DATE NOT NULL,
  data_recebido DATE, valor DECIMAL(10,2) DEFAULT 0,
  status TEXT DEFAULT 'pendente', parcela INT DEFAULT 1, total_parcelas INT DEFAULT 1,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE recebimentos ENABLE ROW LEVEL SECURITY;
CREATE POLICY "p_receb" ON recebimentos FOR ALL USING (auth.uid()=user_id) WITH CHECK (auth.uid()=user_id);

CREATE TABLE despesas_variaveis (
  id TEXT PRIMARY KEY, user_id UUID REFERENCES auth.users NOT NULL,
  data DATE NOT NULL, descricao TEXT NOT NULL, categoria TEXT,
  valor DECIMAL(10,2) DEFAULT 0, created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE despesas_variaveis ENABLE ROW LEVEL SECURITY;
CREATE POLICY "p_despesas" ON despesas_variaveis FOR ALL USING (auth.uid()=user_id) WITH CHECK (auth.uid()=user_id);

CREATE TABLE compras_estoque (
  id TEXT PRIMARY KEY, user_id UUID REFERENCES auth.users NOT NULL,
  data DATE NOT NULL, insumo_id TEXT, insumo_nome TEXT,
  qtd DECIMAL(10,2) DEFAULT 0, valor_total DECIMAL(10,2) DEFAULT 0,
  parcelas INT DEFAULT 1,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE compras_estoque ENABLE ROW LEVEL SECURITY;
CREATE POLICY "p_compras" ON compras_estoque FOR ALL USING (auth.uid()=user_id) WITH CHECK (auth.uid()=user_id);

CREATE TABLE financiamentos (
  id TEXT PRIMARY KEY, user_id UUID REFERENCES auth.users NOT NULL,
  descricao TEXT NOT NULL,
  parcela_valor DECIMAL(10,2) DEFAULT 0,
  parcelas_total INT DEFAULT 1,
  parcelas_pagas INT DEFAULT 0,
  data_inicio DATE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE financiamentos ENABLE ROW LEVEL SECURITY;
CREATE POLICY "p_fin" ON financiamentos FOR ALL USING (auth.uid()=user_id) WITH CHECK (auth.uid()=user_id);

CREATE TABLE metas_mensais (
  id TEXT PRIMARY KEY, user_id UUID REFERENCES auth.users NOT NULL,
  mes TEXT NOT NULL, faturamento DECIMAL(10,2) DEFAULT 0, atendimentos INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE metas_mensais ENABLE ROW LEVEL SECURITY;
CREATE POLICY "p_metas" ON metas_mensais FOR ALL USING (auth.uid()=user_id) WITH CHECK (auth.uid()=user_id);

CREATE TABLE config_clinica (
  user_id UUID PRIMARY KEY REFERENCES auth.users NOT NULL,
  horas DECIMAL(6,2) DEFAULT 139.41,
  imposto DECIMAL(5,2) DEFAULT 6,
  cartao DECIMAL(5,2) DEFAULT 3.5,
  lucro DECIMAL(5,2) DEFAULT 30,
  pro_labore DECIMAL(10,2) DEFAULT 0,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE config_clinica ENABLE ROW LEVEL SECURITY;
CREATE POLICY "p_cfg" ON config_clinica FOR ALL USING (auth.uid()=user_id) WITH CHECK (auth.uid()=user_id);

-- ============================================================
-- MIGRATION (banco existente — execute no SQL Editor)
-- ============================================================
-- ALTER TABLE insumos ADD COLUMN IF NOT EXISTS qtd_por_embalagem DECIMAL(10,4) DEFAULT NULL;
-- ALTER TABLE insumos ADD COLUMN IF NOT EXISTS unidade_uso TEXT DEFAULT NULL;
-- ALTER TABLE procedimentos ADD COLUMN IF NOT EXISTS sessoes_pacote INT DEFAULT 0;
-- ALTER TABLE registros ADD COLUMN IF NOT EXISTS pagamentos JSONB DEFAULT NULL;
-- ALTER TABLE compras_estoque ADD COLUMN IF NOT EXISTS parcelas INT DEFAULT 1;
-- CREATE TABLE IF NOT EXISTS financiamentos (
--   id TEXT PRIMARY KEY, user_id UUID REFERENCES auth.users NOT NULL,
--   descricao TEXT NOT NULL, parcela_valor DECIMAL(10,2) DEFAULT 0,
--   parcelas_total INT DEFAULT 1, parcelas_pagas INT DEFAULT 0,
--   data_inicio DATE, created_at TIMESTAMPTZ DEFAULT NOW()
-- );
-- ALTER TABLE financiamentos ENABLE ROW LEVEL SECURITY;
-- CREATE POLICY "p_fin" ON financiamentos FOR ALL USING (auth.uid()=user_id) WITH CHECK (auth.uid()=user_id);
