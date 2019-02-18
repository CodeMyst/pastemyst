module db;

import mysql : Connection;
import mysql.pool : ConnectionPool;
import appsettings : MySQLSettings;

private ConnectionPool connectionPool;

public void initializeDb (MySQLSettings settings)
{
	connectionPool = ConnectionPool.getInstance (settings.host, settings.user, settings.pwd, settings.db);
}

public Connection getConnection ()
{
    return connectionPool.getConnection ();
}

public void releaseConnection (Connection connection)
{
    connectionPool.releaseConnection (connection);
}

public void createDbTables ()
{
	Connection connection = getConnection ();

	connection.execute ("create table if not exists Users (
							id integer not null primary key,
							login varchar (255) not null,
							email varchar (255) not null
						) engine=InnoDB default charset utf8;");

	// Insert a "null" user
	connection.execute ("insert into Users values (-1, ' ', ' ') on duplicate key update id = -1;");

	connection.execute ("create table if not exists PasteMysts (
							id varchar (255) not null primary key,
							createdAt integer unsigned not null,
							expiresIn varchar (255) not null,
							title varchar (255),
							code longtext not null,
							language varchar (255) not null default 'autodetect',
							labels text,
							ownerId integer,
							isPrivate tinyint (1) not null default 0,
							isEdited tinyint (1) not null default 0,
							constraint `fkOwnerId`
								foreign key (ownerId) references Users (id)
								on delete cascade
								on update cascade
						) engine=InnoDB default charset utf8;");

	connection.execute ("create table if not exists Edits (
							id varchar (255) not null primary key,
							pasteId varchar (255) not null,
							previousEditId varchar (255),
							diff longtext not null,
							date integer unsigned not null,
							constraint `fkPasteId`
								foreign key (pasteId) references PasteMysts (id)
								on delete cascade
								on update cascade,
							constraint `fkPreviousEditId`
								foreign key (previousEditId) references Edits (id)
								on delete cascade
								on update cascade
						) engine=InnoDB default charset utf8;");

	connection.releaseConnection ();
}
