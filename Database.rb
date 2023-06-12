
#$LOAD_PATH.unshift( '/home/everest/angel_libs/ruby/mysql/16.04/' , $BASE + '/lib/ruby/mysql/16.04/' )

require 'mysql2'

class Database

	VERSION = 8.0

	# TO LOG DEBUG OUTPUT FOR THIS LIBRARY SET DEBUG_LEVEL TO -4
	def initialize( username: 'root' , password: 'root-wdcfs01' , ip: '10.6.178.247' , database: 'DEBUG' , port: '3306' , table: nil )

		begin
			@mysql = Mysql2::Client.new( :host => ip , :username => username , :password => password , :database => database , :port => port )

		rescue Exception => error

			eventHandler( error )
		end

		unless table == nil ; setTable( table ) ; end
	end

	def eventHandler( error )

		puts 'MYSQL ERROR : ' + error.message	
	end

	# Sets the database table
	# @return table
	def setTable( table )

		@table = table

		return table
	end

	# Inserts a record into the user defined table
	# @return records id or -1 on error
	def insertRow( data , table = @table )

		# Get column info from table
		columns = @mysql.query( 'SHOW COLUMNS FROM ' + table )

		headers = []

		# Create an array of table headers
		columns.each do |row| headers.push( '`' + row['Field'] + '`' ) end

		# Remove first column header, which is the auto generated ID
		headers.shift(1)

		symbol = ( "?," * headers.count ).chop

		begin
			query = @mysql.prepare 'INSERT INTO ' + table + '(' + ( headers.join( ',') ) + ') values ( ' + symbol + ' )'

			response = query.execute( *data )

			if response == nil ; return_value = @mysql.last_id.to_s ; else return_value = 'MYSQL ERROR : ' + response.to_s ; end 

		rescue Exception => error

			eventHandler( error )
		end

		# Returns the records id
		return return_value
	end

	# Updates a record based on user supplied hash
	# @return '' or -1 on error
	def updateRow(  hash , table = @table )

=begin
Example of required hash

hash = {
	:set	=> {
		:fields=> [ 'sn' , 'fw' ] ,
		:data	=> [ 'SN123' , 'FW123' ] ,
	} ,
	:where	=> {
		:fields=> [ 'sn' , 'fw' ] ,
		:data	=> [ 'ABC456' , 'KNGNP100' ] ,
		:join	=> 'AND' ,
	} ,
}
=end
		set = String.new ; where = String.new

		for x in 0..( hash[ :set ][ :fields ].count - 1 )

			set = set + ( '`' + hash[ :set ][ :fields ][x].to_s + '`' + ' = ' + "'" + hash[ :set ][ :data ][x].to_s + "'" )

			unless ( x == ( hash[ :set ][ :fields ].count - 1 ) ) ; set = set + ' , ' ; end
		end

		for x in 0..( hash[ :where ][ :fields ].count - 1 )

			where = where + ( '`' + hash[ :where ][ :fields ][x].to_s + '`' + ' = ' + "'" + hash[ :where ][ :data ][x].to_s + "'" )

			unless ( x == ( hash[ :where ][ :fields ].count - 1 ) ) ; where = where + ' ' + hash[ :where ][ :join ] + ' ' ; end
		end

		query = 'UPDATE ' + table + ' SET ' + set + ' WHERE ' + where

		begin
			return_value = @mysql.query( query )

		rescue Exception => error

			eventHandler( error )
		end

		return return_value
	end

	# Sends a user defined query to the database
	# @return an array to the query results or nil
	def sendQuery( query )

		data = []

		begin
			return_value = @mysql.query( query )

		rescue Exception => error

			eventHandler( error )
		end

		if return_value.class.to_s == 'Mysql2::Result' 

			return_value.each do |x| ; data.push( x ) ; end

		elsif	return_value.class.to_s == 'NilClass'

			data = nil
		end

		return data
	end

	# Closes database connection
	# @return nil
	def close()
		@mysql.close
	end
end
