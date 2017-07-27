require 'pry'

class Dog

attr_accessor :name, :breed
attr_reader :id

def initialize(name:, breed:, id:nil)
  @name = name
  @breed = breed
  @id = id
end

def self.create_table
  sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dog(
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL
DB[:conn].execute(sql)
end

def self.drop_table
  sql = <<-SQL
    DROP TABLE dogs
    SQL
    DB[:conn].execute(sql)
  end

def save
  sql = <<-SQL
    INSERT INTO dogs (name, breed)
    VALUES(?,?)
  SQL
  DB[:conn].execute(sql, self.name, self.breed)
  @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
  self
end

def update
  sql = <<-SQL
    UPDATE dogs
    SET name = ?, breed = ?
    WHERE id = ?
  SQL
  DB[:conn].execute(sql, self.name, self.breed, self.id)
end

def self.new_from_db(x)
    id = x[0]
    name = x[1]
    breed = x[2]
    self.new(id:id,name:name,breed:breed)
end

def self.create(x)
  self.new(x).save
end

def self.find_by_id(x)
  sql = "SELECT * FROM dogs WHERE id = ?"
  self.new_from_db(DB[:conn].execute(sql, x)[0])
end

def self.find_or_create_by(x)#name:, breed:)
  dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", x[:name], x[:breed])[0]
    if dog == nil
  #  binding.pry
      self.new(x).save
    else
    #  binding.pry
      self.new_from_db(dog)
    end
end

def self.find_by_name(name)
  sql = <<-SQL
    SELECT * FROM dogs
    WHERE name = ?
  SQL
  x = DB[:conn].execute(sql, name)[0]
  Dog.new_from_db(x)
end


end
