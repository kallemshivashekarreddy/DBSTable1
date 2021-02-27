CREATE TABLE Users(
UserId INTEGER IDENTITY(1,1) PRIMARY KEY,
UserName NVARCHAR(200),
Password NVARCHAR(500),
FullName NVARCHAR(200),
Email NVARCHAR(100),
Phone NVARCHAR(50),
RoleId INTEGER FOREIGN KEY REFERENCES Roles(RoleId)
)

ALTER TABLE users
ADD Kyc VARCHAR(200)


ALTER TABLE users
ADD Aadhar VARCHAR(200)

CREATE TABLE Roles(
RoleId INTEGER IDENTITY(1,1) PRIMARY KEY,
RoleName NVARCHAR(100)

)

CREATE TABLE StockMarket(
StockMarketId INTEGER IDENTITY(1,1) PRIMARY KEY,
StockMarketName VARCHAR(100),
IsOpen BIT DEFAULT 0
)

--DROP TABLE Stocks
CREATE TABLE Stocks(
StockId INTEGER IDENTITY(1,1) PRIMARY KEY,
StockName NVARCHAR(100),
StockMarketId INTEGER FOREIGN KEY REFERENCES StockMarket(StockMarketId),
Price DECIMAL(18,2),
TotalQuantity DECIMAL(18,0),
RemainingQuantity DECIMAL(18,0),
Type NVARCHAR(50)
)
-- order id, stock id, ordered quntity , type, executed quantity, executed price,
 --order status, order date 
 --drop table StockOrder
CREATE TABLE StockOrder(
OrderId INTEGER IDENTITY(1,1) PRIMARY KEY,
StockId INTEGER FOREIGN KEY REFERENCES Stocks(StockId),
OrderedQty INTEGER,
RequestedPrice DECIMAL(18,2),
ExecutedPrice DECIMAL(18,2),
OrderStatus VARCHAR(30),
OrderDate DATETIME
)


--INSERT INTO Roles
--SELECT 'Admin'

--INSERT INTO Roles
--SELECT 'Customer'


CREATE PROCEDURE SetUserDetails
@UserId INTEGER=NULL,
@Email VARCHAR(200),
@Password NVARCHAR(500),
@FullName NVARCHAR(200),
@Phone NVARCHAR(100),
@Kyc VARCHAR(200),
@Aadhar VARCHAR(100)
AS
  BEGIN
		IF ISNULL(@UserId,0)=0 SET @UserId=0

		IF(EXISTS(SELECT UserName FROM Users WHERE UserName=@Email))
		BEGIN
				UPDATE Users
				SET FullName=@FullName
					,Phone=@Phone
					,Kyc=@Kyc
					,Aadhar=@Aadhar
					WHERE UserName=@Email
		END
		 ELSE
		BEGIN
			INSERT INTO Users(UserName,FullName,Email,Password,Phone,Aadhar,RoleId)
			SELECT @Email,@FullName,@Email,@Password,@Phone,@Aadhar,2

			SET @UserId=SCOPE_IDENTITY()
		END

		SELECT @UserId
		
  END

  CREATE PROCEDURE UserLogin
  @UserName VARCHAR(100),
  @Password NVARCHAR(500)
  AS
    BEGIN
	    IF(EXISTS(SELECT TOP 1 UserId FROM Users WHERE UserName=@UserName and Password=@Password))
		BEGIN
				SELECT * FROM Users
				WHERE UserName=@UserName and [Password]=@Password
		END
		ELSE
		BEGIN
				SELECT -1,'Incorrect Username or Password'
		END
	END



	CREATE PROCEDURE SetStockMarketStatus
	@IsOpen BIT
	AS
		BEGIN
				UPDATE StockMarket
				SET IsOpen=@IsOpen
		END


		CREATE PROCEDURE GetCustomerStockList
		AS
		  BEGIN
		       
			    SELECT DISTINCT StockId,StockName,RemainingQuantity FROM Stocks

				SELECT DISTINCT [Type] FROM Stocks


		  END



		  ALTER PROCEDURE CreateOrder
		  @UserName NVARCHAR(100)=NULL,
		  @StockId INTEGER=NULL,
		  @StockName NVARCHAR(100)=NULL,
		  @Type NVARCHAR(100),
		  @Price DECIMAL(18,2),
		  @Quantity INTEGER,
		  @StockOrderId INTEGER=NULL
		  AS 
		    BEGIN TRY
						
				DECLARE @UserId INTEGER=NULL
				SET @UserId=(SELECT TOP 1 UserId FROM Users WHERE UserName=@UserName )
				IF((SELECT IsOpen FROM StockMarket)<1)
				BEGIN
						SELECT -1 AS Status,'Stock Market is Currently closed!  Cannot proceed with order' AS Message
						RETURN
				END
					IF((SELECT TOP 1 RemainingQuantity FROM Stocks 
					WHERE StockId = @StockId OR StockName=@StockName)<@Quantity)
					BEGIN
						SELECT -1 AS Status,'Insufficient Stocks, pls order less stocks!' AS Message
						RETURN
					END

					INSERT INTO StockOrder(StockId
										,OrderedQty
										,RequestedPrice
										,OrderStatus
										,OrderDate
										,OrderedBy)
										
					SELECT @StockId,@Quantity,@Price,'Pending',GETDATE(),@UserId
					SET @StockOrderId = SCOPE_IDENTITY()

					
					SELECT 1 AS Status,'Stock Order Request Submitted Sucessfully! Admin will review and update Status!' AS Message
			END TRY
			BEGIN CATCH 
			  SELECT -1 AS Status, ERROR_MESSAGE() AS Message
			END CATCH





			ALTER PROCEDURE GETStockOrders
			@FromDate DATETIME=NULL,
			@ToDate DATETIME=NULL,
			@StockName NVARCHAR(200)=NULL
			AS 
			  BEGIN
					SELECT OrderId
,A.StockId,B.StockName
,OrderedQty
,RequestedPrice
,ExecutedPrice
,OrderStatus
,OrderDate
,UserId
,OrderedBy 
FROM StockOrder a
					JOIN Stocks b on a.StockId=b.stockId
					WHERE (@StockName IS NULL OR b.StockName=@StockName) AND OrderDate BETWEEN @FromDate AND @ToDate
			  END



			ALTER PROCEDURE ApproveRejectOrders
			  @StockId INTEGER,
			  @StockQuantity INTEGER,
			  @Price DECIMAL(18,2)
			  AS
			  BEGIN
			  if((select IsOpen from stockmarket) = 1) 
			  BEGIN
					select -1,'stock market is close cannot proceed with orders' 
					return 
			END
					
					UPDATE StockOrder
					SET ExecutedPrice=@Price,
					OrderStatus='Accepted'
					WHERE StockId=@StockId AND RequestedPrice>=@Price

					UPDATE StockOrder
					SET ExecutedPrice=@Price,
					OrderStatus='Rejected'
					WHERE StockId=@StockId AND RequestedPrice<@Price

					UPDATE Stocks

					SET RemainingQuantity=TotalQuantity-@StockQuantity
					where StockId=@StockId

			  END