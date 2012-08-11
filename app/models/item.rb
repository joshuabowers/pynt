class Item < Widget
  embedded_in :inventory, polymorphic: true
end
