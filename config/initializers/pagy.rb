# set global defaults and extra variables
# they will get merged with every new Pagy instance
Pagy::DEFAULT[:limit]    = 25
# Pagy::DEFAULT[:some_var] = 'default value'

# # create a new instance (usually done automatically by the #pagy controller method)
# pagy = Pagy.new(count: 1000, page: 3, instance_var: 'instance var')
# #=> #<Pagy:0x000056070d954330 ... >

# # fetch variables (with global default)
# pagy.vars[:some_var]
# #=> "default value"

# # fetch variables passed to the instance
# pagy.vars[:instance_var]
# #=> "instance var"

# # fetch instance attributes
# pagy.limit
# #=> 25

# # get the page series
# pagy.series
# #=> [1, 2, "3", 4, 5, 6, 7, :gap, 40]

Pagy::DEFAULT.freeze
