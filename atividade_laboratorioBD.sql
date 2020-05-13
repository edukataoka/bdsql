create database dudu
go
use dudu

create table cliente (
cod_cliente int primary key,
nome varchar(150),
telefone varchar(11)
)

create table produto(
cod_produto int primary key,
nome varchar(150),
valor_unitario decimal(7,2)
)

create table venda(
cod_cliente int, 
cod_produto int,  
data_hora date,  
quantidade int,  
valor_unit decimal(7,2),  
valor_total decimal (7,2),  
foreign key (cod_cliente) references cliente (cod_cliente),
foreign key (cod_produto) references produto (cod_produto),
Primary key(cod_cliente, cod_produto, data_hora) 
)

create table bonus(
id int,
valor decimal(7,2),
premio varchar(100)
)

insert into cliente values
(1, 'Bruninho','11585836812'),
(2, 'Nicholinhas','11585837777'),
(3, 'Dudu','11585838888'),
(4, 'Gilbertinho','11585839999'),
(5, 'Zé','11585831111'),
(6, 'Edinho','1158582222')

insert into bonus values
(1,1000,'jogo de copos'),
(2,2000,'Jogo de pratos'),
(3,3000,'Jogo de talheres'),
(4,4000,'Jogo de porcelana'),
(5,5000,'Jogo de cristais')



insert into produto values
(1, 'monitor', 1000),
(2, 'televisor', 2000.50),
(3, 'notebook', 3200),
(4, 'tablet', 1000.50),
(5, 'freezer', 1500),
(6, 'geladeira',2999.3),
(7, 'projetor de video',5000.3)


-- insere na tabela venda (três atributos)
-- output para mensagem da última variável 

CREATE PROCEDURE sp_dudu_insere_venda 
(@cod_cliente INT, @cod_produto INT, @quantidade INT,@mensagem VARCHAR(80) OUTPUT)


AS
	DECLARE @contador_produto INT,
			@contador_cliente INT,
			@valor_unitario DECIMAL(7,2),
			@valor_total DECIMAL(7,2)

	SET @contador_produto = (SELECT COUNT(*) FROM Produto WHERE cod_produto = @cod_produto)
	SET @contador_cliente = (SELECT COUNT(*) FROM Cliente WHERE cod_cliente = @cod_cliente)

	-- se o contador for maior que 0 AND contador do cliente maior que 0
	IF (@contador_produto > 0 AND @contador_cliente >0)
	BEGIN
		SELECT @valor_unitario = valor_unitario FROM Produto WHERE cod_produto = @cod_produto
		SET @valor_total = @valor_unitario * @quantidade  

		INSERT INTO venda VALUES
			(@cod_cliente, @cod_produto,GETDATE(), @quantidade, @valor_unitario, @valor_total)
			SET @mensagem = 'VENDA CADASTRADA'
	END
	ELSE
	BEGIN
		RAISERROR ('NÃO CADASTRADO', 16, 1)  -- RAISERROR (SENÃO)
	END


DECLARE @resp VARCHAR(100)  -- variável da resposta
EXEC sp_dudu_insere_venda 1, 7, 1, @resp OUTPUT   --cliente, produto, quantidade
PRINT @resp   -- imprime a resposta


select * from produto
select * from cliente
select * from venda

-- função que retorna tabela 

CREATE FUNCTION fn_duduBonusCli() RETURNS @tabela TABLE(
cd_cli      INT,
num_cli    VARCHAR(120),
tot_gasto DECIMAL(7,2),
val_bonus INT,
premio      VARCHAR(100),
sobra_bonus INT
)
AS
BEGIN
	INSERT @tabela(cd_cli,num_cli,tot_gasto)
		SELECT cliente.cod_cliente, cliente.nome, SUM(valor_total) AS total_gasto 
		FROM cliente 
		JOIN 
		venda ON Venda.cod_cliente = cliente.cod_cliente
		GROUP BY cliente.cod_cliente, cliente.nome  --soma de tudo o que o cliente gastou na loja
	--bonus numero inteiro
	UPDATE @tabela SET val_bonus = CAST(tot_gasto AS INT) --total gasto inteiro
	-- max - o maior prêmio que a pessoa pode ganhar (retorna um único valor)
	-- primeiro select seleciona o valor do segundo select
	UPDATE @tabela SET premio = (SELECT premio FROM Bonus 
	WHERE valor = ( select MAX(valor) FROM Bonus WHERE valor <= val_bonus))

	--sobra do bonus, quando menor que o premio = 0
	UPDATE @tabela SET sobra_bonus = (val_bonus -(select MAX(valor) FROM Bonus WHERE valor <= val_bonus))
	RETURN 
END

SELECT * FROM fn_duduBonusCli()
