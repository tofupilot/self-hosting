CREATE MIGRATION m16fu4xhf234iiczceln6poxc6eitfmcs2hiiu2o7vjycesy5qrrzq
    ONTO m1axiulorkbpuaocwso4crukf5akrugpl2q5ucjyjhyc6cnrl2jeiq
{
  ALTER TYPE default::Primitive {
      ALTER PROPERTY name {
          DROP CONSTRAINT std::max_len_value(100);
      };
  };
  ALTER TYPE default::Primitive {
      ALTER PROPERTY name {
          CREATE CONSTRAINT std::max_len_value(200);
      };
  };
};
