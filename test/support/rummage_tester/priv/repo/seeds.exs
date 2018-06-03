alias RummageTester.{Category, Employee, Product, Repo}

[category_1, category_2] = for i <- 1..2 do
  %Category{
    name: "Name #{i}",
    description: "This Category includes #{i} related Products"
  }
end |> Enum.map(&Repo.insert!/1)

[category_3, category_4] = for i <- 3..4 do
  %Category{
    name: "Name #{i}",
    description: "This Category includes #{i} related Products",
    parent_category_id: i - 2
  }
end |> Enum.map(&Repo.insert!/1)

for i <- 1..4 do
  %Product{
    name: "Product #{i}000",
    internal_code: "#{i}000",
    price: i * 10.0,
    availability: i < 3,
    description: "#{i} Product is awesome!"
  }
end |> Enum.map(&Repo.insert!/1)

for i <- 1..4 do
  %Employee{
    first_name: "Employee #{i}",
    last_name: "MYEmployee #{i}",
    date_of_birth: elem(Date.new(2000 + 2 * i, 1 + i, 20 + i), 1),
  }
end |> Enum.map(&Repo.insert!/1)
