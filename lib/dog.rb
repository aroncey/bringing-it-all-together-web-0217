require "pry"
class Dog
  attr_accessor :name, :breed, :id

  def initialize(name: , breed: , id:nil )
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
      sql = <<-SQL
        CREATE TABLE IF NOT EXISTS
        dogs (
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

    if !self.id
      sql = <<-SQL
         INSERT INTO dogs
         (name, breed)
         VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      sql_id = <<-SQL
         SELECT last_insert_rowid()
         FROM dogs
      SQL
      self.id = DB[:conn].execute(sql_id).flatten[0]
      self
    else
      sql = <<-SQL
        UPDATE dogs
        SET name = ?, grade = ?, WHERE id = ?
      SQL
      DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
    self
  end

  def self.create(hash)
    new_dog = Dog.new(hash)
    new_dog.save
  end

  def self.find_by_id(id_val)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
    SQL

    new_d = DB[:conn].execute(sql, id_val).flatten

    new_d_hash = {name: new_d[1], breed: new_d[2], id: new_d[0]}
    Dog.new(new_d_hash)
  end

  def self.find_or_create_by(hash)
    # binding.pry
    name = hash.fetch(:name)
    breed = hash.fetch(:breed)

    dog = DB[:conn].execute("SELECT * FROM dogs WHERE breed = ? AND name = ?", breed, name)
      if !dog.empty?
        dog_data = dog[0]
        dog = Dog.new(name: dog_data[1], breed: dog_data[2], id: dog_data[0])
      else
        create_hash = {name: name, breed: breed, id:nil}
        dog = Dog.create(create_hash)
      end
      dog
  end

  def self.new_from_db(row)
    # dog_hash = {id: row[0], name: row[1], breed: row[2]}
    dog = Dog.new(id: row[0], name: row[1], breed: row[2])
    dog
  end

  def self.find_by_name(name)

    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL
    answer = DB[:conn].execute(sql, name).flatten
    dog = Dog.new(id: answer[0], name: answer[1], breed: answer[2])
  end

  def update

    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL

    # binding.pry
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end


end
