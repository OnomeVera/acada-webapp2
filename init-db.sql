-- Create Database
CREATE DATABASE acada_db;

-- Connect to the database
\c acada_db;

-- Create employees table
CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    department VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    position VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create contacts table
CREATE TABLE contacts (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    email_confirmation_sent BOOLEAN DEFAULT FALSE
);

-- Create indexes for faster queries
CREATE INDEX idx_employees_email ON employees(email);
CREATE INDEX idx_contacts_email ON contacts(email);
CREATE INDEX idx_contacts_created_at ON contacts(created_at DESC);

-- Insert sample employees (optional)
INSERT INTO employees (name, email, department, phone, position) VALUES
('John Doe', 'john.doe@acadalearning.com', 'DevOps', '+1-587-574-2233', 'Senior Engineer'),
('Jane Smith', 'jane.smith@acadalearning.com', 'Cloud', '+1-587-574-2234', 'Cloud Architect'),
('Mike Johnson', 'mike.johnson@acadalearning.com', 'Training', '+1-587-574-2235', 'Training Instructor'),
('Mike agbalumo', 'mike.agbalumo@acadalearning.com', 'Training', '+1-587-574-2236', 'Training Instructor'),
('Emmanuel Okon', 'emmanuel.okon@acadalearning.com', 'HR', '+1-587-574-2237', 'HR Manager'),
('Samuel Jones', 'samuel.jones@acadalearning.com', 'Admin', '+1-587-574-2237', 'Admin Manager'),
('Moses Bliss', 'moses.bliss@acadalearning.com', 'Product', '+1-587-574-2237', 'Product Manager'),
('Joshua David', 'joshua.david@acadalearning.com', 'Finance', '+1-587-574-2237', 'Finance Manager'),
('Samuel Mathew', 'samuel.mathew@acadalearning.com', 'DevOps', '+1-587-574-2237', 'DevOps Manager'),
('Nnacy Jones', 'nnacy.jones@acadalearning.com', 'Finance', '+1-587-574-2237', 'Accountant'),
('Abigail Brown', 'abigail.brown@acadalearning.com', 'HR', '+1-587-574-2237', 'HR Officerr'),
('Emma Wilson', 'emma.wilson@acadalearning.com', 'Customer Experience', '+1-587-574-2237', 'Customer ExperienceManager'),
('Fiona Green', 'fiona.green@acadalearning.com', 'Software', '+1-587-574-2237', 'Software Manager');