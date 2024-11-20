CREATE MIGRATION m1txa7ndhylpfdmpbzlnink43ig3ulxzrbgadys6qujne7z44swg6q
    ONTO m1zhbmrqcrkb3e7q7n5jt5ia3byavldaiozq3mairizg6lijhkv5ea
{
  ALTER TYPE default::Primitive {
      ALTER LINK assignee {
          RENAME TO user;
      };
  };
  ALTER SCALAR TYPE default::PrimitiveNamespace EXTENDING enum<Product, Requirement, Issue, ActionTemplate, Action>;
};
