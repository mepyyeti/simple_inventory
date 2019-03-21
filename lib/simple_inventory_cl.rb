#!/usr/bin/env ruby
#simple_inventory_cl.rb

require 'sqlite3'

class Inv
	attr_reader :item, :stock, :desc
	
	def item=(item)
		@item = item
	end
	
	def stock=(stock=1)
		@stock = Integer(stock)
	end

	def initialize(item='nothing',**specs)
		self.item = item
		self.stock = specs[:stock]
		@desc = specs[:desc]
	end

	def run(item, furthermore)
		begin
			db = SQLite3::Database.open('inventory.db')
			puts db.get_first_value "select SQLite_VERSION()"
			db.transaction
			#db.execute2 "drop table stock"
			db.execute2 "create table if not exists stock(Id INTEGER PRIMARY KEY, Product TEXT, RO TEXT, Level INTEGER, RO_at INTEGER, Description TEXT)"
			puts "foo"
			db.execute2 "insert into stock(Product, Level, RO_at, Description) values(:Product, :Level, :RO_at, :Description)", item, furthermore[:stock], furthermore[:reorder_lvl], furthermore[:desc]
			db.commit
			puts db.changes.to_s + " change"
			puts "You added #{item}, with stock level #{stock}"
			puts "#{item} is described as: #{desc}."
			puts
			print_me = db.execute2 "select * from stock where Product = :item" , item
			print_me.each { |p| puts "%3s %-10s -%-3s- [%5s] %-5s %20s" % [p[0],p[1],p[2],p[3],p[4],p[5]] }
			puts
		rescue SQLite3::Exception => e
			print "error in run " , e
			db.rollback
		ensure
			db.close if db
		end
	end
	
	def summary
		begin
			db = SQLite3::Database.open('inventory.db')
			return "no match" unless File.exists?('inventory.db')
			all = db.execute2 "SELECT * from stock"
			puts
			puts "this is your current inventory"
			all.each { |p| puts "%3s %-10s -%-3s- [%5s] %-5s %20s " % [p[0],p[1],p[2],p[3],p[4],p[5]]}
			puts
		rescue SQLite3::Exception => e
			puts "error in summary " , e
		ensure
			db.close if db
		end
	end
	
	def delete(id_prod)
		begin
			db = SQLite3::Database.open('inventory.db')
			db.transaction
			db.execute2 "DELETE from stock WHERE Id = :id_prod OR Product = :id_prod", id_prod
			db.commit
			puts db.changes.to_s + " deletion"
		rescue SQLite3::Exception => e
			puts "error in delete " , e
			db.rollback
		ensure
			db.close if db
		end
	end
		
	
	def find_to_change(id_prod)
		begin
			db = SQLite3::Database.open('inventory.db')
			print_out = db.execute2 "Select * from stock where Id = :id_prod OR Product = :id_prod" ,id_prod 
			puts
			print_out.each { |line| puts "%3s %-10s -%-3s- [%5s] %-5s %20s" % [line[0], line[1], line[2], line[3], line[4], line[5]]} 
			puts
			pull = db.execute2 "Select Level from stock where Id = :id_prod OR Product = :id_prod" ,id_prod 
			@pull = Integer(pull[1][0])
		rescue SQLite3::Exception => e
			puts "error in find_to_change " , e
		ensure
			db.close if db
		end
		@pull
	end
	
	def sell_replenish(new_quant, id_prod)
		begin
			db = SQLite3::Database.open('inventory.db')
			puts new_quant.class
			db.transaction
			db.execute2 "UPDATE stock SET Level = :new_quant WHERE Id = :id_prod OR Product = :id_prod" , new_quant, id_prod 
			db.commit
			puts db.changes.to_s + " change"
		rescue SQLite3::Exception => e
			puts "error in sell_replenish ", e
			db.rollback
		ensure
			db.close if db
		end
	end
	
	def reorder(id_prod)
		begin
			db = SQLite3::Database.open('inventory.db')
			current_level = db.execute2 "SELECT Level from stock WHERE Id = :id_prod OR Product = :id_prod", id_prod
			@current_level = Integer(current_level[1][0])
			reorder_level = db.execute2 "SELECT RO_at from stock WHERE Id = :id_prod OR Product = :id_prod", id_prod
			@reorder_level = Integer(reorder_level[1][0])
			if @current_level <= @reorder_level
				replenish = "YES"
			else
				replenish = ''
			end	
			db.transaction
			db.execute2 "UPDATE stock SET RO = :replenish WHERE Id = :id_prod OR Product = :id_prod", replenish, id_prod
			db.commit
			puts db.changes.to_s + " change"
			print_out = db.execute2 "SELECT * from stock WHERE Id = :id_prod OR Product = :id_prod", id_prod
			puts
			print_out.each { |p| puts "%3s %-10s -%-3s- [%5s] %-5s %20s" % [p[0],p[1],p[2],p[3],p[4],p[5]]}
			puts
		rescue SQLite3::Exception => e
			puts "error in reorder method " , e
			db.rollback
		ensure
			db.close if db
		end
		@replenish = replenish
	end	
end
