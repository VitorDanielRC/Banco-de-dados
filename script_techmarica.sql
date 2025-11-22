DROP DATABASE IF EXISTS techmarica_producao;
CREATE DATABASE IF NOT EXISTS techmarica_producao;
USE techmarica_producao;

CREATE TABLE IF NOT EXISTS funcionarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cargo VARCHAR(60) NOT NULL,
    area_atuacao VARCHAR(60) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    ativo TINYINT(1) NOT NULL DEFAULT 1,
    data_admissao DATE NOT NULL,
    salario DECIMAL(10,2) NOT NULL,
    CHECK (salario >= 0)
);

CREATE TABLE IF NOT EXISTS maquinas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    codigo_maquina VARCHAR(20) NOT NULL UNIQUE,
    nome VARCHAR(80) NOT NULL,
    tipo VARCHAR(80) NOT NULL,
    setor VARCHAR(60) NOT NULL,
    status_operacional ENUM('ATIVA','MANUTENCAO','INATIVA') NOT NULL DEFAULT 'ATIVA'
);

CREATE TABLE IF NOT EXISTS produtos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    codigo_interno VARCHAR(20) NOT NULL UNIQUE,
    nome_comercial VARCHAR(100) NOT NULL,
    responsavel_tecnico_id INT NOT NULL,
    custo_estimado DECIMAL(10,2) NOT NULL,
    data_criacao DATE NOT NULL DEFAULT (CURDATE()),
    CHECK (custo_estimado >= 0),
    CONSTRAINT fk_produto_responsavel
        FOREIGN KEY (responsavel_tecnico_id) REFERENCES funcionarios(id)
);

CREATE TABLE IF NOT EXISTS ordens_producao (
    id INT AUTO_INCREMENT PRIMARY KEY,
    produto_id INT NOT NULL,
    maquina_id INT NOT NULL,
    funcionario_autorizou_id INT NOT NULL,
    data_inicio DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_conclusao DATETIME NULL,
    quantidade INT NOT NULL DEFAULT 1,
    status ENUM('EM_PRODUCAO','FINALIZADA','CANCELADA') NOT NULL DEFAULT 'EM_PRODUCAO',
    observacoes VARCHAR(255),
    CHECK (quantidade > 0),
    CONSTRAINT fk_ordem_produto
        FOREIGN KEY (produto_id) REFERENCES produtos(id),
    CONSTRAINT fk_ordem_maquina
        FOREIGN KEY (maquina_id) REFERENCES maquinas(id),
    CONSTRAINT fk_ordem_func_autorizou
        FOREIGN KEY (funcionario_autorizou_id) REFERENCES funcionarios(id)
);

-- AQUI ESTÁ CORRIGIDO
ALTER TABLE produtos
ADD COLUMN descricao VARCHAR(255) NULL AFTER nome_comercial;

INSERT INTO funcionarios (nome, cargo, area_atuacao, email, ativo, data_admissao, salario) VALUES
('Ana Silva',      'Engenheira Eletrônica',    'P&D',        'ana.silva@techmarica.com',       1, '2020-03-10',  9500.00),
('Bruno Costa',    'Técnico de Produção',      'Produção',   'bruno.costa@techmarica.com',     1, '2021-07-01',  4200.00),
('Carla Souza',    'Coordenadora de Produção', 'Produção',   'carla.souza@techmarica.com',     1, '2018-01-15', 11000.00),
('Diego Lima',     'Analista de Qualidade',    'Qualidade',  'diego.lima@techmarica.com',      0, '2019-11-20',  6000.00),
('Eduardo Pereira','Engenheiro de Automação',  'P&D',        'eduardo.pereira@techmarica.com', 1, '2022-02-05',  8800.00);

INSERT INTO maquinas (codigo_maquina, nome, tipo, setor, status_operacional) VALUES
('SMT-01', 'Linha SMT 01',              'Montagem de Placas', 'Produção',  'ATIVA'),
('SMT-02', 'Linha SMT 02',              'Montagem de Placas', 'Produção',  'MANUTENCAO'),
('INS-01', 'Estação de Testes Iniciais','Teste',              'Qualidade', 'ATIVA');

INSERT INTO produtos (codigo_interno, nome_comercial, responsavel_tecnico_id, custo_estimado, data_criacao, descricao) VALUES
('P-SEN-001',  'Sensor de Umidade Hídrica',         1,  35.50, '2022-05-10', 'Sensor para agricultura de precisão'),
('P-PLACA-010','Placa Controladora IoT',           5, 120.00, '2021-09-01', 'Placa IoT para automação residencial'),
('P-MOD-007',  'Módulo Inteligente de Iluminação', 1,  89.90, '2023-01-20', 'Módulo Wi-Fi para controle de iluminação'),
('P-GTW-003',  'Gateway Industrial TechMaricá',    5, 450.00, '2020-11-05', 'Gateway para integração de máquinas industriais'),
('P-SEN-010',  'Sensor de Temperatura Industrial', 1,  40.00, '2019-03-14', 'Sensor de alta precisão para ambientes severos');

INSERT INTO ordens_producao (produto_id, maquina_id, funcionario_autorizou_id, data_inicio, data_conclusao, quantidade, status, observacoes) VALUES
(1, 1, 3, '2024-10-01 08:00:00', '2024-10-01 16:30:00', 500, 'FINALIZADA',  'Lote piloto para cliente interno'),
(2, 1, 3, '2024-10-05 09:00:00', NULL,                  300, 'EM_PRODUCAO', 'Ordem contínua para estoque'),
(3, 2, 5, '2024-10-10 07:30:00', NULL,                  150, 'EM_PRODUCAO', 'Aguardando liberação da máquina'),
(4, 3, 1, '2024-09-20 10:00:00', '2024-09-22 18:00:00',  80, 'FINALIZADA',  'Produção para testes de campo'),
(5, 1, 2, '2024-11-01 14:00:00', NULL,                  220, 'EM_PRODUCAO', 'Lote com prioridade alta');

UPDATE funcionarios
SET ativo = 0
WHERE id = 2;

DELETE FROM ordens_producao
WHERE id = 9999;

SELECT
    op.id AS ordem_id,
    op.data_inicio,
    op.data_conclusao,
    op.status,
    op.quantidade,
    p.codigo_interno,
    p.nome_comercial AS produto,
    m.codigo_maquina,
    m.nome AS maquina,
    f_aut.nome AS funcionario_autorizou
FROM ordens_producao op
INNER JOIN produtos p
        ON op.produto_id = p.id
INNER JOIN maquinas m
        ON op.maquina_id = m.id
INNER JOIN funcionarios f_aut
        ON op.funcionario_autorizou_id = f_aut.id
ORDER BY op.data_inicio DESC;

SELECT
    id,
    nome,
    cargo,
    area_atuacao,
    email,
    ativo
FROM funcionarios
WHERE ativo = 0;

SELECT
    f.id,
    f.nome AS responsavel_tecnico,
    COUNT(p.id) AS total_produtos
FROM funcionarios f
LEFT JOIN produtos p
       ON p.responsavel_tecnico_id = f.id
GROUP BY f.id, f.nome
HAVING total_produtos > 0
ORDER BY total_produtos DESC;

SELECT
    id,
    codigo_interno,
    nome_comercial
FROM produtos
WHERE nome_comercial LIKE 'S%';

SELECT
    p.id,
    p.nome_comercial,
    p.data_criacao,
    TIMESTAMPDIFF(YEAR, p.data_criacao, CURDATE()) AS idade_anos
FROM produtos p;

SELECT
    m.nome AS maquina,
    m.codigo_maquina,
    op.status,
    COUNT(op.id) AS total_ordens
FROM maquinas m
LEFT JOIN ordens_producao op
       ON op.maquina_id = m.id
GROUP BY m.id, m.nome, m.codigo_maquina, op.status
ORDER BY m.nome, op.status;

SELECT
    op.id,
    p.nome_comercial AS produto,
    op.data_inicio,
    op.status
FROM ordens_producao op
INNER JOIN produtos p ON p.id = op.produto_id
WHERE op.data_conclusao IS NULL
  AND op.status = 'EM_PRODUCAO';

SELECT
    id,
    UPPER(nome) AS nome_maiusculo,
    email,
    SUBSTRING_INDEX(email, '@', -1) AS dominio_email
FROM funcionarios;

SELECT
    op.id,
    p.nome_comercial AS produto,
    op.data_inicio
FROM ordens_producao op
INNER JOIN produtos p ON p.id = op.produto_id
WHERE op.data_inicio >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
ORDER BY op.data_inicio DESC;

CREATE OR REPLACE VIEW vw_painel_producao AS
SELECT
    op.id AS ordem_id,
    op.data_inicio,
    op.data_conclusao,
    op.status,
    op.quantidade,
    p.codigo_interno,
    p.nome_comercial,
    f_resp.nome AS responsavel_tecnico,
    f_aut.nome  AS funcionario_autorizou,
    m.codigo_maquina,
    m.nome AS maquina_nome,
    m.setor AS setor_maquina
FROM ordens_producao op
INNER JOIN produtos p
        ON op.produto_id = p.id
INNER JOIN maquinas m
        ON op.maquina_id = m.id
INNER JOIN funcionarios f_aut
        ON op.funcionario_autorizou_id = f_aut.id
INNER JOIN funcionarios f_resp
        ON p.responsavel_tecnico_id = f_resp.id;

DELIMITER //

CREATE PROCEDURE sp_registrar_ordem_producao (
    IN p_produto_id INT,
    IN p_funcionario_autorizou_id INT,
    IN p_maquina_id INT
)
BEGIN
    INSERT INTO ordens_producao (
        produto_id,
        maquina_id,
        funcionario_autorizou_id,
        data_inicio,
        status,
        quantidade
    )
    VALUES (
        p_produto_id,
        p_maquina_id,
        p_funcionario_autorizou_id,
        NOW(),
        'EM_PRODUCAO',
        1
    );

    SELECT CONCAT('Ordem criada. ID: ', LAST_INSERT_ID()) AS mensagem;
END //

CREATE TRIGGER trg_ordem_finalizada_ao_definir_conclusao
BEFORE UPDATE ON ordens_producao
FOR EACH ROW
BEGIN
    IF NEW.data_conclusao IS NOT NULL
       AND OLD.data_conclusao IS NULL
       AND OLD.status <> 'FINALIZADA' THEN
        SET NEW.status = 'FINALIZADA';
    END IF;
END //

DELIMITER ;
