CREATE MIGRATION m1wa5dxw3mn4i6nmppcfqxhigpwp4iodykesubu7wtdonwtcsuwt6q
    ONTO m1crlzdm5754yxzrlbe5xee23re2m3ucp2p5vutxug3m4eb25ez4aa
{
  ALTER TYPE default::Primitive {
      CREATE MULTI LINK statusChanges := (.<primitive[IS activity::StatusChange]);
  };
};
