#!/usr/bin/env ruby
#simple_inventory.rb

require './simple_inventory_cl.rb'

go = true

while go
	puts "::SIMPLE Inventory:: Collaborate => https://github.com/mepyyeti/simple_inv"
	puts
	puts "enter [1] to ADD an item\nenter [2] to DELETE an item"
	puts "enter [3] to SUBTRACT an amount\nenter [4] to REPLENISH"
	puts "enter [5] to VIEW INVENTORY \nenter [6] to EXIT"
	choice = gets.chomp
	
	unless choice.empty? == false
		next
	end
	
	choice = Integer(choice)

	if choice == 1
		print "enter item: "
		item = gets.chomp

		if item.empty? then next end

		puts "item: empty? #{item.empty?} nil? #{item.nil?} string? #{item.is_a?(String)}"
		print "amount: "
		stock = Integer(gets.chomp)
		puts stock.class

		while stock < 1
			print "amount: "
			stock = Integer(gets.chomp)
		end
		
		stock = Integer(stock)
		rl = true

		while rl 
			print "set a reorder level: "
			reorder_lvl = gets.chomp
			
			while reorder_lvl.empty? || reorder_lvl.nil?
				print "set a NUMERIC reorder level: "
				reorder_lvl = gets.chomp
			end

			reorder_lvl = Integer(reorder_lvl)
			furthermore = {reorder_lvl: reorder_lvl}

			unless reorder_lvl >= 1
				puts "reorder level must be greater than 1"
				next
			end

			rl = false
		end

		print "want to enter an item description? [y/n]: "
		choice = gets.chomp.downcase
		
		unless choice == 'n' || choice =='no' || choice == '' || choice == ' '
			puts "enter a description of 20 char or less: "
			extra = gets.chomp
		
			if extra.size > 20
				"description is too long."
				next
			else
				"acceptable."
			end
			
			furthermore = {stock: stock, reorder_lvl: reorder_lvl, desc: extra}
		else
			furthermore = {stock: stock, reorder_lvl: reorder_lvl}
		end
		
		x = Inv.new(item, furthermore)
		x.run(item,furthermore)

	elsif choice == 2
		id_prod_hash = {stock: 1, desc: 'just viewing'}
		x = Inv.new(id_prod_hash)
		summary = x.summary 
		
		if summary == false then next end
		
		print "type id number OR product name to delete item: "
		id_or_prod = gets.chomp.downcase
		print "Confirm deletion? [y/n]? :"
		confirm = gets.chomp.downcase
		
		unless confirm == 'y' || confirm == 'yes'
			puts "deletion aborted...returned to main screen options"
			next
		else
			x.delete(id_or_prod)
		end

	elsif choice == 3 || choice == 4
		id_prod_hash = {stock: 1, desc: 'just viewing'}
		y = Inv.new(id_prod_hash)
		summary = y.summary 
		
		if summary == false then next end
		
		direct = "type id number OR product name: "
		print " #{direct}"
		id_or_prod = gets.chomp.downcase
		
		while id_or_prod.empty? || id_or_prod.nil?
			print " #{direct}"
			id_or_prod = gets.chomp.downcase
		end

		pulled = y.find_to_change(id_or_prod)
		pulled = Integer(pulled)
		
		if choice == 3
			add_subtract = "sold"
			print "How many #{add_subtract}? "
			sold = Integer(gets.chomp)
		
			if sold < 0 
				sold = abs(sold)
			end
		
			new_quant = pulled - sold

		else
			add_subtract = "do you want to replenish"
			print "How many #{add_subtract}? "
			sold = Integer(gets.chomp)
		
			if sold < 0 
				sold = abs(sold)
			end
		
			new_quant = pulled + sold	
		end
		
		y.sell_replenish(new_quant, id_or_prod)
		y.reorder(id_or_prod)

	elsif choice == 5
		id_prod_hash = {stock: 1, desc: 'just viewing'}
		z = Inv.new(id_prod_hash)
		z.summary

	elsif choice == 6
		go = false

	else
		next
	end
end
