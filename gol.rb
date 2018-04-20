require 'rspec/autorun'
require 'set'

class Cell
  attr_reader :alive, :neighbors

  def initialize(alive: true)
    @alive = alive
    @neighbors = Set.new
  end

  def alive?
    alive
  end

  def add_neighbors(new_neighbors)
    new_neighbors = Array(new_neighbors).reject do |new_neighbor|
      neighbors.include?(new_neighbor)
    end

    neighbors.merge(new_neighbors)
    new_neighbors.each do |neighbor|
      neighbor.add_neighbors(self)
    end
  end

  def living_neighbors
    neighbors.select(&:alive?).count
  end
end

describe Cell do

  it 'should be alive' do
    expect(Cell.new).to be_alive
  end

  it 'can be dead' do
    expect(Cell.new(alive: false)).not_to be_alive
  end

  it 'has no neighbors by default' do
    expect(Cell.new.neighbors).to be_empty
  end

  it 'can be given a neighbor' do
    neighbor = Cell.new
    cell = Cell.new
    cell.add_neighbors(neighbor)
    expect(cell.neighbors).to include(neighbor)
  end

  it 'becomes a neighbor of the new neighbor' do
    neighbor = Cell.new
    cell = Cell.new
    cell.add_neighbors(neighbor)
    expect(neighbor.neighbors).to include(cell)
  end

  it 'can be given neighbors' do
    neighbor = Cell.new
    cell = Cell.new
    cell.add_neighbors([neighbor])
    expect(cell.neighbors).to include(neighbor)
  end

  it 'can get alive neighbors' do
    neighbor = Cell.new(alive: true)
    dead_neighbor = Cell.new(alive: false)
    cell = Cell.new
    cell.add_neighbors([neighbor, dead_neighbor])
    expect(cell.living_neighbors).to eq(1)
  end
end

class LordOfTheCells
  attr_reader :cell

  def initialize(cell:)
    @cell = cell
  end

  def next
    rules = [
      two_and_alive,
      three
    ]

    Cell.new(alive: rules.any?)
  end

  def two_and_alive
    cell.alive? && cell.living_neighbors == 2
  end

  def three
    cell.living_neighbors == 3
  end
end

describe LordOfTheCells do
  context 'when alive' do
    it 'returns a dead cell if the cell has no neighbors' do
      cell = Cell.new
      expect(LordOfTheCells.new(cell: cell).next).not_to be_alive
    end

    it 'returns a living cell if the cell has two neighbors' do
      cell = Cell.new
      cell.add_neighbors([Cell.new, Cell.new])

      expect(LordOfTheCells.new(cell: cell).next).to be_alive
    end

    it 'returns a dead cell if the cell has four neighbors' do
      cell = Cell.new
      cell.add_neighbors([Cell.new, Cell.new, Cell.new, Cell.new])

      expect(LordOfTheCells.new(cell: cell).next).not_to be_alive
    end
  end

  context 'when dead' do
    it 'returns a dead cell if the cell has two neighbors' do
      cell = Cell.new(alive: false)
      cell.add_neighbors([Cell.new, Cell.new])

      expect(LordOfTheCells.new(cell: cell).next).not_to be_alive
    end

    it 'returns a living cell if the cell has three neighbors' do
      cell = Cell.new(alive: false)
      cell.add_neighbors([Cell.new, Cell.new, Cell.new])

      expect(LordOfTheCells.new(cell: cell).next).to be_alive
    end
  end
end

class Grid
  def initialize(initial_state: [])
    set_cells(initial_state)
  end

  def root
    cells.first.first
  end

  def set_cells(initial_state)
    cell_rows = initial_state.map do |states|
      states.map do |state|
        Cell.new(alive: state)
      end
    end

    @cells = cell_rows.each_with_index.map do |cells, row|
      cells.each_with_index.map do |cell, column|
        neighbors = [
          cell_rows&.at(row)&.at(column+1),
          cell_rows&.at(row+1)&.at(column+1),
          cell_rows&.at(row+1)&.at(column),
        ].compact

        cell.add_neighbors(neighbors)
        cell
      end
    end
  end

  private

  attr_reader :cells
end


describe Grid do
  it 'create a cell at a location' do
    config = [
      [false, true, false],
      [false, true, false],
      [false, true, false],
    ]
    grid = Grid.new(initial_state: config)

    expect(grid.root).not_to be_alive
  end

  it 'create a cell at al location' do
    config = [
      [false, true, false],
      [false, true, false],
      [false, true, false],
    ]
    grid = Grid.new(initial_state: config)

    expect(grid.root.neighbors.count).to eq(3)
  end
end