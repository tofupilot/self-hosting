CREATE MIGRATION m1tn5tfojrcjx5m7ft7g6xjoscyi4bcoeqtynxr7g5pftklxalu4aq
    ONTO m1vakqu44k2lrqem7m2sn4tgjj4sxfms3zxsxv2qsepk5eexok757a
{
  ALTER TYPE default::Upload {
      CREATE REQUIRED PROPERTY s3Key -> std::str {
          SET REQUIRED USING ('');
          CREATE CONSTRAINT std::exclusive;
      };
  };
};
