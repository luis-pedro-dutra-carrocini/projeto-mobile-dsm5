const express = require("express");
const cors = require("cors");
const { Pool } = require("pg");

require("dotenv").config();
const porta = process.env.PORT || 3000;

const app = express();

app.use(cors());
app.use(express.json());

console.log(process.env.NODE_ENV);
console.log(process.env.PORT);

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
});

app.get('/', (req, res) => {
  res.json({
    mensagem: 'API Controle Dividas funcionando...',
    rotas: [
      'GET /teste-banco',
      'GET /dividas',
      'POST /dividas',
      'PUT /dividas/:id',
      'PATCH /dividas/:id/status',
      'DELETE /dividas/:id',
      'GET /contatos',
      'POST /contatos',
      'GET /contatos/:id',
      'PUT /contatos/:id',
      'DELETE /contatos/:id'
    ]
  });
});

app.get("/teste-banco", async (req, res) => {
  try {
    const resultado = await pool.query("select now()");

    res.json({
      mensagem: "Conexão com o banco realizada com sucesso",
      dataHoraBanco: resultado.rows[0].now,
    });
  } catch (erro) {
    console.error("Erro ao conectar com o banco:", erro);

    res.status(500).json({
      erro: "Erro interno do servidor...",
    });
  }
});

app.get("/criar-tabela-dividas", async (req, res) => {
  try {
    await pool.query(`
      create table if not exists dividas (
        id serial primary key,
        valor numeric(10,2) not null,
        numero_conta integer not null,
        descricao varchar(255),
        status varchar(20) default 'pendente',
        data_criacao timestamp default current_timestamp
      )
    `);

    res.json({
      mensagem: "Tabela dividas criada com sucesso",
    });
  } catch (erro) {
    console.error("Erro ao criar tabela:", erro);

    res.status(500).json({
      erro: "Erro ao criar tabela dividas",
    });
  }
});

app.get("/dividas", async (req, res) => {
  try {
    const resultado = await pool.query(
      "select id, valor, numero_conta, descricao, status, data_criacao from dividas order by id desc",
    );

    res.json(resultado.rows);
  } catch (erro) {
    console.error("erro ao buscar dívidas:", erro);

    res.status(500).json({
      erro: "Erro Interno do servidor...",
    });
  }
});

app.post('/dividas', async (req, res) => {
  try {
    const { valor, numeroConta, descricao } = req.body;

    if (!valor || valor <= 0) {
      return res.status(400).json({
        erro: 'Valor deve ser maior que zero'
      });
    }

    if (!numeroConta || numeroConta <= 0) {
      return res.status(400).json({
        erro: 'Número da Conta deve ser maior que zero'
      });
    }

    const resultado = await pool.query(
      `insert into dividas (valor, numero_conta, descricao)
       values ($1, $2, $3)
       returning id, valor, numero_conta, descricao, status`,
      [valor, numeroConta, descricao]
    );

    res.status(201).json({
      mensagem: 'Dívida cadastrada com sucesso',
      divida: resultado.rows[0]
    });
  } catch (erro) {
    console.error('Erro ao cadastrar dívida:', erro);

    res.status(500).json({
      erro: 'Erro interno do servidor...'
    });
  }
});

// Alterar Dívida
app.put('/dividas/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { valor, numeroConta, descricaoDivida } = req.body;

    // Verificar se a dívida existe
    const dividaExistente = await pool.query(
      'select id from dividas where id = $1',
      [id]
    );

    if (dividaExistente.rows.length === 0) {
      return res.status(404).json({
        erro: 'Dívida não encontrada'
      });
    }

    // Validações
    if (valor !== undefined && valor <= 0) {
      return res.status(400).json({
        erro: 'Valor deve ser maior que zero'
      });
    }

    if (numeroConta !== undefined && numeroConta <= 0) {
      return res.status(400).json({
        erro: 'Número da Conta deve ser maior que zero'
      });
    }

    // Construir query dinâmica
    const updates = [];
    const values = [];
    let paramCount = 1;

    if (valor !== undefined) {
      updates.push(`valor = $${paramCount++}`);
      values.push(valor);
    }
    if (numeroConta !== undefined) {
      updates.push(`numero_conta = $${paramCount++}`);
      values.push(numeroConta);
    }
    if (descricaoDivida !== undefined) {
      updates.push(`descricao = $${paramCount++}`);
      values.push(descricaoDivida);
    }

    if (updates.length === 0) {
      return res.status(400).json({
        erro: 'Nenhum campo para atualizar'
      });
    }

    values.push(id);
    const query = `
      update dividas 
      set ${updates.join(', ')}
      where id = $${paramCount}
      returning id, valor, numero_conta, descricao, status
    `;

    const resultado = await pool.query(query, values);

    res.json({
      mensagem: 'Dívida atualizada com sucesso',
      divida: resultado.rows[0]
    });
  } catch (erro) {
    console.error('Erro ao alterar dívida:', erro);
    res.status(500).json({
      erro: 'Erro interno do servidor...'
    });
  }
});

// Alterar status da dívida para paga
app.patch('/dividas/:id/status', async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    // Verificar se a dívida existe
    const dividaExistente = await pool.query(
      'select id, status from dividas where id = $1',
      [id]
    );

    if (dividaExistente.rows.length === 0) {
      return res.status(404).json({
        erro: 'Dívida não encontrada'
      });
    }

    // Se status foi enviado no body, usa ele, senão marca como 'paga'
    const novoStatus = status || 'paga';
    
    // Validar status permitidos
    const statusPermitidos = ['pendente', 'paga', 'cancelada'];
    if (!statusPermitidos.includes(novoStatus)) {
      return res.status(400).json({
        erro: 'Status inválido. Use: pendente, paga ou cancelada'
      });
    }

    const resultado = await pool.query(
      `update dividas 
       set status = $1 
       where id = $2
       returning id, valor, numero_conta, descricao, status`,
      [novoStatus, id]
    );

    res.json({
      mensagem: `Status da dívida alterado para ${novoStatus}`,
      divida: resultado.rows[0]
    });
  } catch (erro) {
    console.error('Erro ao alterar status da dívida:', erro);
    res.status(500).json({
      erro: 'Erro interno do servidor...'
    });
  }
});

// Deletar dívida
app.delete('/dividas/:id', async (req, res) => {
  try {
    const { id } = req.params;

    // Verificar se a dívida existe
    const dividaExistente = await pool.query(
      'select id from dividas where id = $1',
      [id]
    );

    if (dividaExistente.rows.length === 0) {
      return res.status(404).json({
        erro: 'Dívida não encontrada'
      });
    }

    await pool.query(
      'delete from dividas where id = $1',
      [id]
    );

    res.json({
      mensagem: 'Dívida deletada com sucesso',
      id: parseInt(id)
    });
  } catch (erro) {
    console.error('Erro ao deletar dívida:', erro);
    res.status(500).json({
      erro: 'Erro interno do servidor...'
    });
  }
});

app.get("/criar-tabela-contatos", async (req, res) => {
  try {
    await pool.query(`
      create table if not exists contatos (
        id serial primary key,
        nome varchar(100) not null,
        numero_conta integer not null
      )
    `);

    res.json({
      mensagem: "Tabela contatos criada com sucesso",
    });
  } catch (erro) {
    console.error("Erro ao criar tabela contatos:", erro);

    res.status(500).json({
      erro: "Erro Interno do Servidor...",
    });
  }
});

app.get("/contatos", async (req, res) => {
  try {
    const resultado = await pool.query(
      "select id, nome, numero_conta from contatos order by id desc",
    );

    res.json(resultado.rows);
  } catch (erro) {
    console.error("Erro ao buscar contatos:", erro);

    res.status(500).json({
      erro: "Erro Interno do Servidor...",
    });
  }
});

app.post("/contatos", async (req, res) => {
  try {
    const { nome, numeroConta } = req.body;

    if (!nome || nome.trim() === "") {
      return res.status(400).json({
        erro: "nome é obrigatório!",
      });
    }

    if (!numeroConta || numeroConta <= 0) {
      return res.status(400).json({
        erro: "numeroConta deve ser maior que zero!",
      });
    }

    const resultado = await pool.query(
      `insert into contatos (nome, numero_conta)
       values ($1, $2)
       returning id, nome, numero_conta`,
      [nome, numeroConta],
    );

    res.status(201).json({
      mensagem: "Contato cadastrado com sucesso",
      contato: resultado.rows[0],
    });
  } catch (erro) {
    console.error("Erro ao cadastrar contato:", erro);

    res.status(500).json({
      erro: "Erro interno do Servidor...",
    });
  }
});

app.get('/contatos/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const resultado = await pool.query(
      'select id, nome, numero_conta from contatos where id = $1',
      [id]
    );

    if (resultado.rows.length === 0) {
      return res.status(404).json({
        erro: 'Contato não encontrado'
      });
    }

    res.json(resultado.rows[0]);
  } catch (erro) {
    console.error('Erro ao buscar contato por id:', erro);

    res.status(500).json({
      erro: 'Erro interno do Servidor...'
    });
  }
});

// Alterar contato
app.put('/contatos/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { nome, numeroConta } = req.body;

    // Verificar se o contato existe
    const contatoExistente = await pool.query(
      'select id from contatos where id = $1',
      [id]
    );

    if (contatoExistente.rows.length === 0) {
      return res.status(404).json({
        erro: 'Contato não encontrado'
      });
    }

    // Validações
    if (nome !== undefined && nome.trim() === "") {
      return res.status(400).json({
        erro: 'Nome não pode estar vazio'
      });
    }

    if (numeroConta !== undefined && numeroConta <= 0) {
      return res.status(400).json({
        erro: 'Número da Conta deve ser maior que zero'
      });
    }

    // Construir query dinâmica
    const updates = [];
    const values = [];
    let paramCount = 1;

    if (nome !== undefined) {
      updates.push(`nome = $${paramCount++}`);
      values.push(nome);
    }
    if (numeroConta !== undefined) {
      updates.push(`numero_conta = $${paramCount++}`);
      values.push(numeroConta);
    }

    if (updates.length === 0) {
      return res.status(400).json({
        erro: 'Nenhum campo para atualizar'
      });
    }

    values.push(id);
    const query = `
      update contatos 
      set ${updates.join(', ')}
      where id = $${paramCount}
      returning id, nome, numero_conta
    `;

    const resultado = await pool.query(query, values);

    res.json({
      mensagem: 'Contato atualizado com sucesso',
      contato: resultado.rows[0]
    });
  } catch (erro) {
    console.error('Erro ao alterar contato:', erro);
    res.status(500).json({
      erro: 'Erro interno do servidor...'
    });
  }
});

// Deletar contato
app.delete('/contatos/:id', async (req, res) => {
  try {
    const { id } = req.params;

    // Verificar se o contato existe
    const contatoExistente = await pool.query(
      'select id from contatos where id = $1',
      [id]
    );

    if (contatoExistente.rows.length === 0) {
      return res.status(404).json({
        erro: 'Contato não encontrado'
      });
    }

    await pool.query(
      'delete from contatos where id = $1',
      [id]
    );

    res.json({
      mensagem: 'Contato deletado com sucesso',
      id: parseInt(id)
    });
  } catch (erro) {
    console.error('Erro ao deletar contato:', erro);
    res.status(500).json({
      erro: 'Erro interno do servidor...'
    });
  }
});

app.listen(porta, () => {
  console.log(`Servidor rodando na porta ${porta} ...`);
});