CREATE MIGRATION m143lrvcxmcz6b2ylfm4e5s3wrwcsi344oy6fkt2ubd5eb2whpcfda
    ONTO m1tn5tfojrcjx5m7ft7g6xjoscyi4bcoeqtynxr7g5pftklxalu4aq
{
  ALTER TYPE default::Upload {
      ALTER PROPERTY content_type {
          RESET OPTIONALITY;
      };
  };
  ALTER TYPE default::Upload {
      ALTER PROPERTY etag {
          RESET OPTIONALITY;
      };
  };
  ALTER TYPE default::Upload {
      ALTER PROPERTY size {
          RESET OPTIONALITY;
      };
  };
};
