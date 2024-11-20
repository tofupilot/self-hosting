CREATE MIGRATION m16u3vjz3iudrc5p6h454i4fe2znv5wetfdzjox6aolodxalnb2fba
    ONTO m1rqby2yrgusgzwjjck7mxwntf3pwrtawrpatr3f3ohddmz5pdpfsa
{
  ALTER TYPE default::Primitive {
      CREATE MULTI LINK categoryChanges := (.<primitive[IS activity::CategoryChange]);
  };
};
