import flask
from flask import request, jsonify
app = flask.Flask(__name__)
# app.config["DEBUG"] = True
# Create some test data for our customers in the form of a list of dictionaries.
customers = [
    {
    "id": 1,
    "Username": "Tucker",
    "Gender": "male",
    "DateOfBirth": "1978-02-17",
    "KnownAs": "Tucker",
    "Created": "2020-01-04",
    "LastActive": "2020-01-04",
    "Interests": "Velit aliquip commodo anim aute incididunt consectetur.",
    "City": "Cedarville",
    "Country": "Saudi Arabia"
  },
  {
    "id": 2,
    "Username": "Martin",
    "Gender": "male",
    "DateOfBirth": "1989-10-24",
    "KnownAs": "Martin",
    "Created": "2020-04-30",
    "LastActive": "2020-04-30",
    "Interests": "Duis in nisi eu elit anim mollit nulla.",
    "City": "Tioga",
    "Country": "Luxembourg"
  },
  {
    "id": 3,
    "Username": "Deanne",
    "Gender": "female",
    "DateOfBirth": "1996-05-15",
    "KnownAs": "Deanne",
    "Created": "2020-06-11",
    "LastActive": "2020-06-11",
    "Interests": "Eu ullamco elit occaecat laborum non nisi minim cillum anim qui proident.",
    "City": "Snyderville",
    "Country": "Burundi"
  },
  {
       "id": 4,
    "Username": "Dionne",
    "Gender": "female",
    "DateOfBirth": "1972-04-07",
    "KnownAs": "Dionne",
    "Created": "2020-02-26",
    "LastActive": "2020-02-26",
    "Interests": "Minim officia minim duis fugiat dolor eiusmod incididunt.",
    "City": "Kipp",
    "Country": "Papua New Guinea"
  }
]
results = []
@app.route('/', methods=['GET'])
def home():
    return 'OK'
@app.route('/v1/devops/customers', methods=['GET'])
def api_get():
    if 'id' in request.args:
        id = int(request.args['id'])
    else:
        return jsonify(customers)
    for customer in customers:
        if customer['id'] == id:
            results.append(customer)
            return jsonify(results)
@app.route("/v1/devops/customers",  methods = ['POST'])
def api_insert():
    customer = request.get_json()
    customers.append(customer)
    return "Success: Customer information has been added."
@app.route("/v1/devops/customers/<id>", methods=["DELETE"])
def api_delete(id):
    for customer in customers:
        if customer['id'] == int(id):
            customers.remove(customer)
    return "Success: Customer information has been deleted."
if __name__ == '__main__':
    app.run(host="0.0.0.0", port=3000)