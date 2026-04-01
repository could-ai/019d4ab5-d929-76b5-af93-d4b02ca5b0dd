import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'الهيكل التنظيمي',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        fontFamily: 'Tahoma', // خط مناسب للغة العربية
      ),
      // دعم اتجاه النص من اليمين لليسار (RTL)
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      initialRoute: '/',
      routes: {
        '/': (context) => const OrgChartScreen(),
      },
    );
  }
}

// نموذج بيانات الموظف
class Employee {
  final String id;
  final String name;
  final String role;
  final String? managerId;

  Employee({
    required this.id,
    required this.name,
    required this.role,
    this.managerId,
  });
}

class OrgChartScreen extends StatefulWidget {
  const OrgChartScreen({super.key});

  @override
  State<OrgChartScreen> createState() => _OrgChartScreenState();
}

class _OrgChartScreenState extends State<OrgChartScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _roleController = TextEditingController();
  String? _selectedManagerId;

  // بيانات افتراضية للبدء
  List<Employee> employees = [
    Employee(id: '1', name: 'أحمد محمود', role: 'المدير التنفيذي', managerId: null),
    Employee(id: '2', name: 'سارة خالد', role: 'مدير الموارد البشرية', managerId: '1'),
    Employee(id: '3', name: 'محمد علي', role: 'مدير التقنية', managerId: '1'),
  ];

  // دالة إضافة موظف جديد
  void _addEmployee() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        employees.add(
          Employee(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: _nameController.text,
            role: _roleController.text,
            managerId: _selectedManagerId,
          ),
        );
        _nameController.clear();
        _roleController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تمت إضافة الموظف بنجاح')),
      );
    }
  }

  // دالة حذف موظف (تحذف الموظف وكل من يتبعه في الهيكل)
  void _deleteEmployee(String id) {
    setState(() {
      void deleteNodeAndChildren(String nodeId) {
        final children = employees.where((e) => e.managerId == nodeId).toList();
        for (var child in children) {
          deleteNodeAndChildren(child.id);
        }
        employees.removeWhere((e) => e.id == nodeId);
      }
      
      deleteNodeAndChildren(id);
      
      if (_selectedManagerId == id) {
        _selectedManagerId = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('منشئ الهيكل التنظيمي', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // تصميم متجاوب: شاشات كبيرة (ويب/ديسكتوب) مقابل شاشات صغيرة (جوال)
          if (constraints.maxWidth > 800) {
            return Row(
              children: [
                SizedBox(
                  width: 350,
                  child: _buildInputPanel(),
                ),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(
                  child: _buildChartPanel(),
                ),
              ],
            );
          } else {
            return Column(
              children: [
                SizedBox(
                  height: 350,
                  child: _buildInputPanel(),
                ),
                const Divider(height: 1, thickness: 1),
                Expanded(
                  child: _buildChartPanel(),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  // لوحة إدخال البيانات
  Widget _buildInputPanel() {
    // التأكد من أن المدير المحدد لا يزال موجوداً (في حال تم حذفه)
    if (_selectedManagerId != null && !employees.any((e) => e.id == _selectedManagerId)) {
      _selectedManagerId = null;
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.grey.shade50,
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            const Text(
              'إضافة موظف جديد',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'اسم الموظف',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) => value == null || value.isEmpty ? 'الرجاء إدخال الاسم' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _roleController,
              decoration: const InputDecoration(
                labelText: 'المسمى الوظيفي',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.work),
              ),
              validator: (value) => value == null || value.isEmpty ? 'الرجاء إدخال المسمى الوظيفي' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String?>(
              value: _selectedManagerId,
              decoration: const InputDecoration(
                labelText: 'المدير المباشر',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.manage_accounts),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('بدون مدير (رأس الهيكل)'),
                ),
                ...employees.map((e) => DropdownMenuItem(
                  value: e.id,
                  child: Text('${e.name} - ${e.role}'),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedManagerId = value;
                });
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _addEmployee,
              icon: const Icon(Icons.add),
              label: const Text('إضافة للهيكل التنظيمي', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // لوحة عرض الهيكل التنظيمي
  Widget _buildChartPanel() {
    final roots = employees.where((e) => e.managerId == null).toList();
    
    if (roots.isEmpty) {
      return const Center(
        child: Text('لا يوجد بيانات في الهيكل التنظيمي. قم بإضافة موظفين.', style: TextStyle(fontSize: 18)),
      );
    }

    // InteractiveViewer يسمح بالتكبير والتصغير والسحب
    return InteractiveViewer(
      constrained: false,
      boundaryMargin: const EdgeInsets.all(double.infinity),
      minScale: 0.1,
      maxScale: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: roots.map((root) => _buildNode(root)).toList(),
        ),
      ),
    );
  }

  // بناء عقدة (موظف) واحدة في الهيكل بشكل متكرر (Recursive)
  Widget _buildNode(Employee employee) {
    final children = employees.where((e) => e.managerId == employee.id).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // بطاقة الموظف
          Stack(
            clipBehavior: Clip.none,
            children: [
              Card(
                elevation: 6,
                shadowColor: Colors.teal.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.teal.shade200, width: 2),
                ),
                child: Container(
                  width: 180,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.teal.shade50],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.teal.shade100,
                        radius: 24,
                        child: Text(
                          employee.name.isNotEmpty ? employee.name.substring(0, 1) : '?',
                          style: TextStyle(color: Colors.teal.shade900, fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        employee.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        employee.role,
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              // زر الحذف
              Positioned(
                top: -10,
                left: -10,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _deleteEmployee(employee.id),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.cancel, color: Colors.redAccent, size: 24),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // رسم الفروع والأبناء
          if (children.isNotEmpty) ...[
            // خط عمودي نازل من الأب
            Container(width: 2, height: 24, color: Colors.teal.shade300),
            // خط أفقي يربط الأبناء (يظهر فقط إذا كان هناك أكثر من ابن)
            Container(
              decoration: children.length > 1
                  ? BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.teal.shade300, width: 2),
                      ),
                    )
                  : null,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: children.map((child) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // خط عمودي نازل لكل ابن (إذا كان هناك أكثر من ابن)
                      if (children.length > 1)
                        Container(width: 2, height: 24, color: Colors.teal.shade300),
                      // استدعاء الدالة بشكل متكرر لرسم الابن
                      _buildNode(child),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
