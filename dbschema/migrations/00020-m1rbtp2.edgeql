CREATE MIGRATION m1rbtp2uritqecpzs52h4wt4jkq6s4saxvy33tgz2kok6ttph3flhq
    ONTO m143lrvcxmcz6b2ylfm4e5s3wrwcsi344oy6fkt2ubd5eb2whpcfda
{
  ALTER TYPE default::Upload {
      CREATE MULTI LINK primitives -> default::Primitive {
          ON TARGET DELETE ALLOW;
      };
  };
  ALTER TYPE default::Primitive {
      CREATE MULTI LINK uploads := (.<primitives[IS default::Upload]);
  };
};
