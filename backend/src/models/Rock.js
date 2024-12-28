const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Rock = sequelize.define('Rock', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
    allowNull: false,
  },
  name: {
    type: DataTypes.STRING,
    allowNull: false
  },
  category: {
    type: DataTypes.STRING,
    allowNull: false
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: false
  },
  properties: {
    type: DataTypes.JSON,
    defaultValue: {}
  },
  color: {
    type: DataTypes.JSON,
    defaultValue: []
  },
  imageUrl: DataTypes.STRING,
  common_uses: DataTypes.TEXT,
  imageQuality: DataTypes.STRING,
  confidenceLevel: DataTypes.STRING,
  userId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'Users',
      key: 'id'
    }
  }
});

module.exports = Rock;
